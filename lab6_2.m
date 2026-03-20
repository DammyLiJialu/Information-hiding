function main()
    clc; clear; close all;
    
    % 创建输出目录
    if ~exist('./pic6', 'dir')
        mkdir('./pic6');
    end

    % 读取载体图像
    cover = imread('2.jpg');
    figure; imshow(cover); title('载体图像');
    saveas(gcf, './pic6/origional2.png');

    % 准备待隐藏数据
    secret_num = 2211985;              % 需要隐藏的数字
    secret_img = imread('binary_xiaohui.jpg'); % 需要隐藏的二值图像
    secret_img = imresize(secret_img, 0.3);  % 缩小为原来的 30%，便于隐藏

    
    % 执行信息隐藏
    watermarked = AdvancedHide(cover, secret_num, secret_img);
    
    % 信息提取
    AdvancedExtract(watermarked, size(secret_img));
end

%% 增强版隐藏函数
function watermarked = AdvancedHide(cover, num, img)
    watermarked = cover;
    
    % 预处理秘密图像
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    bin_img = imbinarize(img);
    [h, w] = size(bin_img);
    
    % 强制转为16位无符号整数
    h = uint16(h);
    w = uint16(w);
    
    % 生成二进制数据流（关键修正）
    num_bits = logical(dec2bin(num, 32) - '0');  % 32位数字
    h_bits = logical(dec2bin(h, 16) - '0');     % 16位高度（补零）
    w_bits = logical(dec2bin(w, 16) - '0');     % 16位宽度（补零）
    img_bits = bin_img(:)';                     % 图像行向量
    
    % 合并数据流
    payload = [num_bits, h_bits, w_bits, img_bits];
    
    % 检查容量
    required = numel(payload);
    if numel(cover) < required
        error('载体容量不足：需要%d像素，当前%d像素', required, numel(cover));
    end
    
    % 嵌入LSB
    for i = 1:required
        watermarked(i) = bitset(cover(i), 1, payload(i));
    end
    
    % 显示结果
    figure; 
    subplot(1,2,1); imshow(cover); title('原始载体');
    subplot(1,2,2); imshow(watermarked); 
    psnr_val = psnr(watermarked, cover);
    title(sprintf('PSNR: %.2f dB', psnr_val));
    saveas(gcf, './pic6/lsb_watermarked2.png');
end
%% 增强版提取函数
function AdvancedExtract(watermarked, orig_size)
    % 提取所有LSB
    bits_stream = false(1, numel(watermarked));
    for i = 1:numel(watermarked)
        bits_stream(i) = bitget(watermarked(i), 1);
    end
    
    % 解析数字（前32位）
    num_bits = bits_stream(1:32);
    secret_num = bin2dec(num2str(num_bits));
    
    % 解析图像尺寸（修正索引范围）
    h_bits = bits_stream(33:48);   % 正确16位高度
    w_bits = bits_stream(49:64);   % 正确16位宽度
    h = bin2dec(num2str(h_bits));
    w = bin2dec(num2str(w_bits));
    
    % 验证尺寸合理性
    expected_pixels = h * w;
    actual_pixels = length(bits_stream) - 64;
    if expected_pixels ~= actual_pixels
        warning('尺寸头信息损坏，使用原始尺寸提取');
        h = orig_size(1);
        w = orig_size(2);
    end
    
    % 重构图像（修复旋转）
    img_data = bits_stream(65:64 + h*w);
    secret_img = reshape(img_data, [h, w]); % 正确维度顺序
    
    % 显示结果
    figure;
    subplot(1,2,1); imshow(secret_img); 
    title(sprintf('提取图像 %dx%d', h, w));
    subplot(1,2,2); imshow(orig_size); 
    title(sprintf('原始图像 %dx%d', orig_size(1), orig_size(2)));
    
    fprintf('提取结果:\n数字: %d\n图像尺寸: %d×%d\n', secret_num, h, w);
end