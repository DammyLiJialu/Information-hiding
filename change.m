% 读取原图像
img = imread('test.jpg');

% 转为灰度图像（如果图像是彩色的）
grayImg = rgb2gray(img);

% 二值化（可以使用自动或自定义阈值）
bwImg = imbinarize(grayImg);  % 自动 Otsu 阈值

% 显示结果
imshow(bwImg);
title('二值图');

% 保存二值图像
imwrite(bwImg, 'binary_image.jpg');  % 保存为 PNG 格式
