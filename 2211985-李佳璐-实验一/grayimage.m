% main() is the main function of the visualCrypGray program.
function main()
    clc;
    clear all;
    close all;

    img_path = input("Please use the absolute path to input the image to be processed: ", 's');
    % img_path = "D:\deskbook\xinxiyincang\1.jpg";
    original_img = imread(img_path);

    % 如果是彩色图像，转换为灰度图
    if size(original_img, 3) == 3
        gray_img = rgb2gray(original_img);
    else
        gray_img = original_img;
    end

    disp("The size of gray_img is: ");
    disp(size(gray_img));
    figure;
    imshow(gray_img);
    title('gray\_img');
    imwrite(gray_img, './gray_img2.jpg');

    % 半色调化处理
    halftone_img = img_halftone(gray_img);
    disp("The size of halftone_img is: ");
    disp(size(halftone_img));
    figure;
    imshow(halftone_img);
    title('halftone\_img');
    imwrite(halftone_img, './halftone_img2.jpg');

    % 改为使用 `imbinarize` 代替 `im2bw`
    binary_original_img = imbinarize(halftone_img);
    disp("The size of binary_original_img is: ");
    disp(size(binary_original_img));
    figure;
    imshow(binary_original_img);
    title('binary\_original\_img');
    imwrite(binary_original_img, './binary_original_img2.jpg');

    % 修正 `img_divide` 逻辑
    [img1, img2] = img_divide(binary_original_img);
    disp("The size of img1 is: ");
    disp(size(img1));
    disp("The size of img2 is: ");
    disp(size(img2));
    figure;
    imshow(img1);
    title('img1');
    imwrite(img1, './2-1.bmp');
    figure;
    imshow(img2);
    title('img2');
    imwrite(img2, './2-2.bmp');

    % 合并图像
    merged_img = img_merge(img1, img2);
    disp("The size of merged_img is: ");
    disp(size(merged_img));
    figure;
    imshow(merged_img);
    title('merged\_img');
    imwrite(merged_img, './merged_img2.bmp');

    % **修改尺寸检查逻辑**
    expected_size = [2 * size(binary_original_img, 1), 2 * size(binary_original_img, 2)];
    if isequal(expected_size, size(merged_img))
        disp('Congratulations');
    else
        error('The size of the original image and the merged image do not match');
    end
end




% img_halftone(gray_img): This function performs halftoning on a grayscale image using error diffusion.
%
% Input:
% - gray_img: The input grayscale image.
%
% Output:
% - img: The halftoned image.
%
function img = img_halftone(gray_img)
    img_size = size(gray_img);
    disp("The size of the gray_img is: ");
    disp(img_size);
    
    %%
    % 该方法无法准确赋值，故而使用后面的分别进行赋值
    % [x, y] = img_size; % x 为 size 的第一个参数，y 为 size 的第二个参数
    %%
    
    x = img_size(1); % x 为 img_size 的第一个参数
    y = img_size(2); % y 为 img_size 的第二个参数
    disp("The first size of the img1 is: ");
    disp(x);
    disp("The second size of the img1 is: ");
    disp(y);

    for m = 1 : x
        for n = 1 : y
            if gray_img(m, n) > 127
                out = 255;
            else
                out = 0;
            end

            error = gray_img(m, n) - out;

            if n > 1 && n < 255 && m < 255
                gray_img(m, n + 1) = gray_img(m, n + 1) + error * 7 / 16.0;  % 右方
                gray_img(m + 1, n) = gray_img(m + 1, n) + error * 5 / 16.0;  % 下方
                gray_img(m + 1, n - 1) = gray_img(m + 1, n - 1) + error * 3 / 16.0;  % 左下方
                gray_img(m + 1, n + 1) = gray_img(m + 1, n + 1) + error * 1 / 16.0;  % 右下方
                gray_img(m, n) = out;
            else
                gray_img(m, n) = out;
            end
        end
    end

    img = gray_img;

end


% img_divide: Divide an input image into two images, img1 and img2, by applying a specific pattern.
%
% Inputs:
%   img - the input image to be divided
%
% Outputs:
%   img1 - the first divided image
%   img2 - the second divided image
%
function [img1, img2] = img_divide(img)
    [x, y] = size(img);
    img1 = 255 * ones(2 * x, 2 * y); % 初始化白色图像
    img2 = 255 * ones(2 * x, 2 * y); 

    for i = 1:x
        for j = 1:y
            new_row = 2 * (i - 1) + 1;
            new_col = 2 * (j - 1) + 1;
            key = randi([0, 1]); % 生成随机模式

            if img(i, j) == 1 % 白色像素（背景）
                if key == 0
                    img1(new_row, new_col) = 0;   img1(new_row, new_col + 1) = 255;
                    img1(new_row + 1, new_col) = 255; img1(new_row + 1, new_col + 1) = 0;

                    img2(new_row, new_col) = 255; img2(new_row, new_col + 1) = 0;
                    img2(new_row + 1, new_col) = 0; img2(new_row + 1, new_col + 1) = 255;
                else
                    img1(new_row, new_col) = 255; img1(new_row, new_col + 1) = 0;
                    img1(new_row + 1, new_col) = 0; img1(new_row + 1, new_col + 1) = 255;

                    img2(new_row, new_col) = 0; img2(new_row, new_col + 1) = 255;
                    img2(new_row + 1, new_col) = 255; img2(new_row + 1, new_col + 1) = 0;
                end
            else % 黑色像素（前景）
                img1(new_row, new_col) = 0; img1(new_row, new_col + 1) = 255;
                img1(new_row + 1, new_col) = 0; img1(new_row + 1, new_col + 1) = 255;

                img2(new_row, new_col) = 0; img2(new_row, new_col + 1) = 255;
                img2(new_row + 1, new_col) = 0; img2(new_row + 1, new_col + 1) = 255;
            end
        end
    end
end





% img_merge: Merge two images using bitwise AND operation.
%
% Input Arguments:
%   - img1: First input image.
%   - img2: Second input image.
%
% Output Argument:
%   - img: Merged image with the same size as img1 and img2.
%
function img = img_merge(img1, img2)
    img = min(img1 + img2, 255); % 确保像素值不超过255
end
