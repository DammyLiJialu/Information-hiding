function main()
    clc; clear; close all;
    
    % 读取图像并预处理
    original_img = imread('original_img.bmp');
    secret_img = imread('secret_binary.bmp');
    
    figure, imshow(secret_img), title('秘密图像');
    % 调整尺寸
    original_img = imresize(original_img, [256, 256]);
    secret_img = imresize(secret_img, [32, 32]);
    
    % 确保二值化（只在需要时调用imbinarize）
    if ~isa(secret_img, 'logical')
        secret_img = imbinarize(secret_img);
    end
    
    % 转为双精度
    original_img = double(original_img);
    secret_img = double(secret_img);

    figure, imshow(uint8(original_img)), title('原图像');
    
    % 隐藏信息（DCT系数差值法）
    [stego_img, ref_coeffs] = Hide_DCT(original_img, secret_img);
    figure, imshow(uint8(stego_img)), title('含密图像');
    
    % 提取信息
    extracted_img = Extract_DCT(stego_img, ref_coeffs);
    figure, imshow(uint8(extracted_img*255)), title('提取图像');
    
    % 评估指标
    psnr_val = psnr(uint8(stego_img), uint8(original_img));
    accuracy = sum(sum(extracted_img == secret_img)) / numel(secret_img);
    fprintf('PSNR: %.2f dB\n提取准确率: %.2f%%\n', psnr_val, accuracy*100);
end

function [stego_img, ref_coeffs] = Hide_DCT(original_img, secret_img)
    block_size = 8;
    [H, W] = size(original_img);
    stego_img = original_img;
    ref_coeffs = zeros(H, W); % 存储原始DCT系数用于提取
    
    secret_idx = 1;
    for i = 1:block_size:H
        for j = 1:block_size:W
            % 提取当前块
            block = original_img(i:i+block_size-1, j:j+block_size-1);
            
            % 计算DCT并保存原始系数
            dct_block = dct2(block);
            ref_coeffs(i:i+block_size-1, j:j+block_size-1) = dct_block;
            
            % 选择中频系数对（用于嵌入1比特）
            coeff_pairs = [
                2 3;  % 系数对1
                3 2;  % 系数对2
                3 3;  % 系数对3
                2 4;  % 系数对4
                4 2]; % 系数对5（5对共10个系数嵌入1比特）
            
            if secret_idx > numel(secret_img)
                secret_bit = 0; % 超出范围填0
            else
                secret_bit = secret_img(secret_idx);
                secret_idx = secret_idx + 1;
            end
            
            % 嵌入逻辑：调整系数对的相对大小
            for k = 1:size(coeff_pairs, 1)
                a = coeff_pairs(k,1);
                b = coeff_pairs(k,2);
                val1 = dct_block(a,b);
                val2 = dct_block(b,a);
                
                if secret_bit == 1
                    % 确保val1 > val2 + ε
                    if val1 <= val2
                        val1 = val2 + 0.1; % ε=0.1（嵌入强度）
                    end
                else
                    % 确保val1 < val2 - ε
                    if val1 >= val2
                        val1 = val2 - 0.1;
                    end
                end
                dct_block(a,b) = val1;
                dct_block(b,a) = val2;
            end
            
            % 逆变换回空域
            stego_block = idct2(dct_block);
            stego_img(i:i+block_size-1, j:j+block_size-1) = stego_block;
        end
    end
end

function extracted_img = Extract_DCT(stego_img, ref_coeffs)
    block_size = 8;
    [H, W] = size(stego_img);
    secret_size = [floor(H/block_size), floor(W/block_size)];
    extracted_img = zeros(secret_size);
    
    secret_idx = 1;
    for i = 1:block_size:H
        for j = 1:block_size:W
            % 提取含密块和原始参考系数
            stego_block = stego_img(i:i+block_size-1, j:j+block_size-1);
            ref_block = ref_coeffs(i:i+block_size-1, j:j+block_size-1);
            
            % 计算含密块的DCT
            dct_stego = dct2(stego_block);
            
            % 提取系数对并判断比特
            coeff_pairs = [
                2 3; 3 2;
                3 3; 2 4;
                4 2]; % 与隐藏时一致的系数对
            
            bit_sum = 0;
            for k = 1:size(coeff_pairs, 1)
                a = coeff_pairs(k,1);
                b = coeff_pairs(k,2);
                val_stego = dct_stego(a,b);
                val_ref = ref_block(a,b); % 原始系数作为参考
                
                % 通过系数变化方向判断嵌入的比特
                if val_stego > val_ref % 嵌入1的特征
                    bit_sum = bit_sum + 1;
                end
            end
            
            % 多数表决确定最终比特（5对中≥3对为1则判1）
            extracted_img(secret_idx) = bit_sum >= 3;
            secret_idx = secret_idx + 1;
        end
    end
    extracted_img = reshape(extracted_img, secret_size);
end