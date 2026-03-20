function main()
    % === 1. 生成：读入载体图像与秘密图像（南开校徽） ===
    cover_img = imread('D:\deskbook\xinxiyincang\origin.jpg');
    cover_gray = rgb2gray(cover_img);
    imwrite(cover_gray, './pic7/star_gray.bmp');

    secret_img = imread('D:\deskbook\xinxiyincang\binary_xiaohui_surpress.jpg');  % 南开校徽图像
    secret_gray = rgb2gray(secret_img);
    imwrite(secret_gray, './pic7/nankai_gray.bmp');

    figure;
    subplot(1, 2, 1); imshow(cover_gray); title('Cover Image');
    subplot(1, 2, 2); imshow(secret_gray); title('Secret Image');
    saveas(gcf, './pic7/cover_and_secret.png');

    % === 2. 加密：秘密图像二值化 + XOR 加密 ===
    secret_bin = imbinarize(secret_gray);  % 二值化
    [m, n] = size(secret_bin);

    key = logical(randi([0, 1], m, n));  % 生成密钥（0或1）
    save('secret_key.mat', 'key');       % 保存密钥以供解密

    secret_enc = xor(secret_bin, key);   % XOR 加密
    figure; imshow(secret_enc); title('Encrypted Secret Image');
    saveas(gcf, './pic7/encrypted_secret.png');

    % === 3. 嵌入：奇偶校验位法嵌入秘密图像 ===
    if size(cover_gray, 1) < 2*m || size(cover_gray, 2) < 2*n
        error('载体图像尺寸不足，请更换更大图像');
    end
    stego_img = Hide(cover_gray, m, n, secret_enc);
    figure; imshow(stego_img); title('Image with Hidden Secret');
    saveas(gcf, './pic7/with_secret.png');

    % === 4. 提取：从载体图像中提取秘密信息 ===
    extracted_bin = Extract(stego_img);
    figure; imshow(extracted_bin); title('Extracted Binary (Un-Decrypted)');
    saveas(gcf, './pic7/extracted_binary.png');

    % === 5. 解密：复原南开校徽图像 ===
    load('secret_key.mat', 'key');               % 加载密钥
    secret_dec = xor(extracted_bin, key);        % XOR 解密
    extracted_logo = uint8(secret_dec * 255);    % 转为可显示的灰度图
    figure; imshow(extracted_logo); title('Decrypted Secret Image');
    imwrite(extracted_logo, './pic7/Extracted_Nankai.bmp');
    saveas(gcf, './pic7/decrypted_secret.png');
end

% === 奇偶校验计算函数：判断一个区域的最低位奇偶性 ===
function result = checksum(x, i, j)
    bits = [
        bitget(x(2*i-1, 2*j-1), 1),
        bitget(x(2*i-1, 2*j), 1),
        bitget(x(2*i, 2*j-1), 1),
        bitget(x(2*i, 2*j), 1)
    ];
    result = mod(sum(bits), 2);
end

% === 隐写函数：将秘密信息嵌入图像中 ===
function result = Hide(x, m, n, y)
    for i = 1:m
        for j = 1:n
            if checksum(x, i, j) ~= y(i, j)
                rand_idx = randi(4);  % 随机选择一个像素反转其 LSB
                switch rand_idx
                    case 1
                        x(2*i-1, 2*j-1) = bitset(x(2*i-1, 2*j-1), 1, ...
                            ~bitget(x(2*i-1, 2*j-1), 1));
                    case 2
                        x(2*i-1, 2*j) = bitset(x(2*i-1, 2*j), 1, ...
                            ~bitget(x(2*i-1, 2*j), 1));
                    case 3
                        x(2*i, 2*j-1) = bitset(x(2*i, 2*j-1), 1, ...
                            ~bitget(x(2*i, 2*j-1), 1));
                    case 4
                        x(2*i, 2*j) = bitset(x(2*i, 2*j), 1, ...
                            ~bitget(x(2*i, 2*j), 1));
                end
            end
        end
    end
    result = x;
end

% === 提取函数：从图像中恢复隐藏的信息 ===
function result = Extract(x)
    [m, n] = size(x);
    m = m / 2; n = n / 2;
    secret = zeros(m, n);
    for i = 1:m
        for j = 1:n
            secret(i, j) = checksum(x, i, j);
        end
    end
    result = logical(secret);  % 返回逻辑图像（0/1）
end
