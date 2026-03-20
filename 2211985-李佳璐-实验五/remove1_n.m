clc;
clear all;
close all;

figure;
img = imread("binary_image.jpg");
imshow(img);
title('原图像');


for t = 1 : 8
    [m, n] = size(img);
    for k = 1 : t
        for i = 1 : m
            for j = 1 : n
                img(i, j) = bitset(img(i, j), k, 0);
            end
        end
    end

    figure;
    imshow(img, []);
    title(['去掉最低 ', num2str(t), ' 个位平面']);
    imwrite(img, ['./pic5/remove1_n_', num2str(t), '.bmp']);
end