clc;
clear all;
close all;

figure;
img = imread("binary_image.jpg");
imshow(img);
title('原图像');

for t = 1 : 8
    [m, n] = size(img);
    x = zeros(m, n);
    y = zeros(m, n);
    z = zeros(m, n);
    for i = 1 : m
        for j = 1 : n
            x(i, j) = bitget(img(i, j), t);
        end
    end

    figure;
    imshow(x, []);
    title(['第 ', num2str(t), ' 个位平面']);
    imwrite(x, ['./pic5/image_', num2str(t), '.jpg']);


    for k = 1 : t
        x = zeros(m, n);

        for i = 1 : m
            for j = 1 : n
                x(i, j) = bitget(img(i, j), k);
            end
        end

        for i = 1 : m
            for j = 1 : n
                y(i, j) = bitset(y(i, j), k, x(i, j));
            end
        end
    end

    figure;
    imshow(y, []);
    title(['第 1 - ', num2str(t), ' 个位平面']);
    imwrite(y, ['./pic5/image1_n_', num2str(t), '.jpg']);

    for k = t + 1 : 8
        x = zeros(m, n);
        for i = 1 : m
            for j = 1 : n
                x(i, j) = bitget(img(i, j), k);
            end
        end
        for i = 1 : m
            for j = 1 : n
                z(i, j) = bitset(z(i, j), k, x(i, j));
            end
        end
    end

    figure;
    imshow(z, []);
    title(['第 ', num2str(t) + 1, ' - 8 个位平面']);
    imwrite(z, ['./pic5/n+1_8_', num2str(t), '.jpg']);
end
    