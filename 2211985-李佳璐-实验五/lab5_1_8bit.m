clc;
clear all;
close all;

figure;
img = imread("binary_image.jpg");
imshow(img);
title('原图像');

for t = 1 : 8
    [m, n] = size(img);
    c = zeros(m, n);
    for i = 1 : m
        for j = 1 : n
            c(i, j) = bitget(img(i, j), t);
        end
    end
    figure;
    imshow(c, []);
    title(['这是第', num2str(t), '个位平面']);
    imwrite(c, ['./pic5/image', num2str(t), '.bmp']);
end