import cv2
import numpy as np
import matplotlib.pyplot as plt

# 读取宿主图像并转换为灰度
host_image = cv2.imread("suzhu.jpg", cv2.IMREAD_GRAYSCALE)
host_h, host_w = host_image.shape

# 计算宿主图像可容纳的块数
bh = host_h // 8
bw = host_w // 8

# 读取二值图像并调整至宿主块数大小
binary_image = cv2.imread("binary_xiaohui.jpg", cv2.IMREAD_GRAYSCALE)
binary_image = cv2.resize(binary_image, (bw, bh), interpolation=cv2.INTER_NEAREST)
_, binary_image = cv2.threshold(binary_image, 128, 255, cv2.THRESH_BINARY)

# 显示
plt.figure(figsize=(6,3))
plt.subplot(1,2,1); plt.imshow(host_image, cmap='gray'); plt.title("Host Image")
plt.subplot(1,2,2); plt.imshow(binary_image, cmap='gray'); plt.title("Binary Image")
plt.show()


def embed_binary_image(host_img, binary_img, alpha=25):
    h, w = host_img.shape
    new_img = host_img.copy().astype(np.float32)

    for i in range(bh):
        for j in range(bw):
            x, y = i * 8, j * 8
            block = new_img[x:x + 8, y:y + 8]
            if block.shape != (8, 8):
                continue

            # DCT变换
            dct_block = cv2.dct(block)
            pos = (1, 1)  # 选择中频系数

            # 获取当前bit (0或1)
            bit = binary_img[i, j] // 255

            # 修改DCT系数（根据bit设置正负）
            dct_block[pos] = alpha if bit else -alpha

            # 逆变换并裁剪防止溢出
            new_block = cv2.idct(dct_block)
            new_block = np.clip(new_block, 0, 255)
            new_img[x:x + 8, y:y + 8] = new_block

    return new_img.astype(np.uint8)


# 嵌入信息
stego_image = embed_binary_image(host_image, binary_image)

# 显示结果
plt.figure(figsize=(6, 3))
plt.imshow(stego_image, cmap='gray')
plt.title("Stego Image")
plt.show()


def extract_binary_image(stego_img):
    h, w = stego_img.shape
    extracted = np.zeros((bh, bw), dtype=np.uint8)

    for i in range(bh):
        for j in range(bw):
            x, y = i * 8, j * 8
            block = stego_img[x:x + 8, y:y + 8]
            if block.shape != (8, 8):
                continue

            dct_block = cv2.dct(block.astype(np.float32))
            pos = (1, 1)

            # 根据系数正负提取bit
            extracted[i, j] = 255 if dct_block[pos] > 0 else 0

    # 放大到8x8块大小显示
    extracted = cv2.resize(extracted, (bw * 8, bh * 8), interpolation=cv2.INTER_NEAREST)
    return extracted


# 提取信息
extracted_binary = extract_binary_image(stego_image)

# 显示提取结果
plt.figure(figsize=(6, 3))
plt.imshow(extracted_binary, cmap='gray')
plt.title("Extracted Binary Image")
plt.show()