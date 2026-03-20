function main()
    try
        % 初始化环境
        clc; clear; close all;
        
        % 创建输出目录（如果不存在）
        output_dir = './pic6/';
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end

        % 读取图像（带错误检查）
        cover_path = '2.jpg';
        message_path = 'm.png';
        
        if ~exist(cover_path, 'file') || ~exist(message_path, 'file')
            error('图像文件未找到，请检查路径');
        end

        cover = imread(cover_path);
        message_orig = imread(message_path);
        
        % 预处理消息图像（强制转换为二值图像）
        message = imbinarize(message_orig);  % 关键改进：确保二值化
        message = imresize(message, size(cover));  % 关键改进：尺寸匹配

        % 显示原始图像
        figure('Name', '原始图像对比');
        subplot(1,2,1);
        imshow(cover);
        title('载体图像 (Cover)');
        subplot(1,2,2);
        imshow(message);
        title('预处理后的消息 (Message)');
        saveas(gcf, fullfile(output_dir, 'original_comparison.png'));

        % 执行LSB隐写
        lsb_watermarked = LSB_Hide(cover, message);
        
        % 提取隐藏信息
        extracted_message = LSB_Extract(lsb_watermarked);
        
        % 计算PSNR评估质量
        psnr_val = psnr(lsb_watermarked, cover);
        fprintf('嵌入后图像PSNR: %.2f dB\n', psnr_val);

        % 显示提取结果
        figure('Name', '提取结果');
        imshow(extracted_message);
        title(['提取的消息 (PSNR: ' num2str(psnr_val, '%.2f') ' dB)']);
        saveas(gcf, fullfile(output_dir, 'extracted_message.png'));

    catch ME
        % 错误处理
        disp('程序运行出错:');
        disp(ME.message);
        disp('Stack trace:');
        for k = 1:length(ME.stack)
            fprintf('File: %s\nName: %s\nLine: %d\n',...
                ME.stack(k).file,...
                ME.stack(k).name,...
                ME.stack(k).line);
        end
    end
end

%% LSB嵌入函数
function watermarked = LSB_Hide(cover, message)
    % 输入验证
    validateattributes(cover, {'uint8'}, {'2d'}, mfilename, 'Cover Image');
    validateattributes(message, {'logical'}, {'2d'}, mfilename, 'Message Image');
    
    % 执行LSB替换
    watermarked = bitset(cover, 1, message);  % 向量化操作提高速度
    
    % 显示结果
    figure('Name', '含水印图像');
    imshow(watermarked);
    title('含水印图像 (LSB Watermarked)');
    imwrite(watermarked, fullfile('./pic6/', 'lsb_watermarked.png'));
end

%% LSB提取函数
function extracted = LSB_Extract(watermarked)
    % 输入验证
    validateattributes(watermarked, {'uint8'}, {'2d'}, mfilename, 'Watermarked Image');
    
    % 提取LSB层
    extracted = logical(bitget(watermarked, 1));  % 直接返回逻辑矩阵
    
    % 可选：后处理（中值滤波去噪）
    % extracted = medfilt2(extracted, [3 3]);
end