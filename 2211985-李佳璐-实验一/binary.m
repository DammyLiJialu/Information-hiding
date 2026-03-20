% main() is the main function of the visualCryp program.
function main()
    clc;
    clear all;
    close all;
    
    img_path = input("Please use the absolute path to input the image to be processed: ", 's');
    % img_path = "D:\deskbook\xinxiyincang\1.jpg";

    % 读取图像并转换为灰度图
    original_img = imread(img_path);
    if size(original_img, 3) == 3
        original_img = rgb2gray(original_img); % 转换为灰度图
    end

    % 进行二值化处理
    threshold = graythresh(original_img); % 计算自适应阈值
    original_img = imbinarize(original_img, threshold); % 二值化

    % 缩小图像尺寸，避免计算量过大
    original_img = imresize(original_img, 0.25);
    
    % 显示并保存二值化后的图像
    disp("The size of the original image is: ");
    disp(size(original_img));
    figure;
    imshow(original_img);
    title('Binarized Original Image');
    imwrite(original_img * 255, './original_img.bmp'); % 保存时转换为 0-255 范围

    % 调用分割函数
    [img1, img2] = img_divide(original_img);
    disp("The size of the divided image is: ");
    disp(size(img1));
    disp(size(img2));
    figure;
    imshow(img1);
    title('img1');
    imwrite(img1, './1-1.bmp');
    figure;
    imshow(img2);
    title('img2');
    imwrite(img2, './1-2.bmp');

    % 调用合并函数
    merged_img = img_merge(img1, img2);
    disp("The size of the merged image is: ");
    disp(size(merged_img));
    figure;
    imshow(merged_img);
    title('merged\_img');
    imwrite(merged_img, './merged_img1.bmp');

    % 检查原始图像和合并图像的尺寸关系
    if isequal(2 * size(original_img), size(merged_img))
        disp('Congratulations');
    else
        error('The size of the original image and the merged image do not match');
    end
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

    img_size = size(img);
    disp("The size of the input image is: ");
    disp(img_size);

    x = img_size(1); % x 为 img_size 的第一个参数
    y = img_size(2); % y 为 img_size 的第二个参数
    img1 = 255 * ones(2 * x, 2 * y); % 将 img1 初始化为全白图像
    img2 = 255 * ones(2 * x, 2 * y); % 将 img2 初始化为全白图像
    disp("The size of the img1 is: ");
    disp(size(img1));
    disp("The size of the img2 is: ");
    disp(size(img2));

    for i = 1 : x
        for j = 1 : y
            new_img_row = 2 * (i - 1) + 1;
            new_img_col = 2 * (j - 1) + 1;
            key = randi(3);

            switch key
                case 1
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row, new_img_col + 1) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    else % original_img is black
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    end

                case 2
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row + 1, new_img_col + 1) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                    else % original_img is black
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                    end

                case 3
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row + 1, new_img_col) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                    else % original_img is black
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    end

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
    img_size = size(img1); % 两张图像的尺寸一致，故而此处以 img1 的 size 作为 img 的 size
    disp("The size of the img1 is: ");
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

    img = 255 * ones(x, y); % 将 img 初始化为全白图像
    disp("The size of the merged img is: ");
    disp(size(img));
    
    for i = 1 : x
        for j = 1 : y
            img(i, j) = img1(i, j) & img2(i, j);
        end
    end

    disp("The size of the merged img is: ");
    disp(size(img));

end
