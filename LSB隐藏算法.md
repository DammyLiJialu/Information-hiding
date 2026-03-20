<h1><center>信息隐藏技术课程实验报告</center></h1>












![image-20241009183344873](C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20241009183344873.png)





<h4><center>实验名称：LSB隐藏法</center><h4>
<h4><center>姓名：李佳璐</center><h4>
<h4><center>学号：2211985</center><h4>
<h4><center>专业：信息安全</center><h4>







<div STYLE="page-break-after: always;"></div>



## 一、实验要求

1. 实现将二值图像嵌入到位图中
2. 实现将学号(一个整数，以及南开校徽二值图)嵌入到位图中

## 二、实验原理

**LSB隐写原理**：

- 修改像素值的最低位对视觉影响极小，适合隐藏信息。
- 嵌入公式：`cover_pixel = (cover_pixel & 254) | message_bit`
- 提取公式：`message_bit = watermarked_pixel & 1`

将秘密信息嵌入载体图像像素值的最低有效位（Least Significant Bit, LSB）。由于人眼对最低位变化不敏感，修改LSB对载体图像的视觉质量影响极小。

- 设载体像素值为 C，秘密数据位为 s∈{0,1}，嵌入后像素值为：

$$
C^′=C−(C mod 2)+s
$$

- **容量计算**：每个像素可隐藏1位信息，总容量为 载体像素数×1 bit载体像素数×1bit。

**多数据类型嵌入**
通过二进制编码支持数字和图像两种数据类型的混合隐藏：

- **数字编码**：32位二进制表示，支持最大整数 232−1232−1。

- **二值图像编码**：

1. 将二值图像展开为行向量，每个像素用1位表示（0=黑，1=白）。
2. 添加16位高度和16位宽度的头信息，支持最大图像尺寸 65535×6553565535×65535。

- **数据流结构**：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250422084210387.png" alt="image-20250422084210387" style="zoom:67%;" />

**质量评估**
使用峰值信噪比（PSNR）量化嵌入后图像的质量：
$$
PSNR=10⋅log⁡_{10}(MAX_I^2/MSE)
$$
其中 MAXI=255（8位图像），MSE为均方误差。



## 三、实验过程

### 1. 将二值图像嵌入到位图中

#### 【实现过程】

**预处理消息图像**：

- **二值化**：`imbinarize`将消息转换为黑白二值图像。
- **尺寸匹配**：`imresize`调整消息图像与载体图像尺寸一致，确保逐像素嵌入

**LSB隐写**：

- 调用`LSB_Hide`将消息嵌入载体，生成含水印图像。

**提取与评估**：

- 调用`LSB_Extract`从含水印图像中提取消息。
- 计算PSNR（峰值信噪比）评估图像质量，值越高表示失真越小。



#### **嵌入函数 `Hide(cover, message)`**

> 将二值消息嵌入载体图像的最低位（LSB）

```matlab
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
```

1. **输入验证**：确保载体是`uint8`类型，消息是二值逻辑矩阵。

2. **向量化嵌入**：

   使用`bitset(cover, 1, message)`将消息的每个比特替换载体对应像素的最低位。

   此操作高效，避免了逐像素循环。



#### **提取函数 `Extract(lsb_watermarked)`**

> 从含水印图像中提取隐藏的消息

```matlab
function Extract(lsb_watermarked)
    [Mw, Nw] = size(lsb_watermarked);
    message = uint8(zeros(size(lsb_watermarked)));

    for i = 1 : Mw
        for j = 1 : Nw
            message(i, j) = bitget(lsb_watermarked(i, j), 1);
        end
    end

    figure;
    imshow(message, []);
    title('Extracted Message Image');
    saveas(gcf, './pic6/extracted.png');
end
```

1. **输入验证**：确保输入为`uint8`类型。
2. **提取LSB**：`bitget(watermarked, 1)`获取每个像素的最低位，直接生成二值逻辑矩阵。



#### 【实验结果】

将message调整大小，经预处理后进行嵌入：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421162713802.png" alt="image-20250421162713802" style="zoom:80%;" />

将message嵌入到位图中：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421162748039.png" alt="image-20250421162748039" style="zoom:67%;" />

提取message：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421163143031.png" alt="image-20250421163143031" style="zoom: 67%;" />

------

### 2. 将学号以及校徽嵌入到位图中

#### 【实现过程】

与前一个实验对比：

现在的**数据负载**是一个拼接起来的长向量：

```python
payload = 学号(32位) + 高度(16位) + 宽度(16位) + 图像像素(若干位)
```

**容量检查逻辑新增**

因为嵌入的信息变多，所以必须检查载体图像是否有足够的空间来承载这些位。`AdvancedHide` 增加了对 `payload` 总长度与 `cover` 容量的比较，如果空间不足就直接报错。

**信息提取过程同步更新**

在 `AdvancedExtract` 中，依次读取前 32 位恢复学号，再读取 32 位恢复图像的尺寸，然后才能知道该从哪一位开始、提取多少位来还原图像。这种结构化的数据提取，就是**“前面加头，后面解析”**的典型设计模式。

​      **整体来说，前一个实验中的 `LSB_Hide` 更像是“直接硬塞一张图进去“，没有管理信息，也没有预处理结构。而现在的 `AdvancedHide` 是“先把要塞进去的内容打包好，再一个个塞进去”，类似真正的“信息编码 + 封包 + 嵌入”的流程。**



**隐藏函数部分：`AdvancedHide`**

前面message 直接嵌入，没有打包，而在 `AdvancedHide` 中：

```matlab
% 编码为二进制
num_bits = logical(dec2bin(num, 32)' - '0');
h_bits = logical(dec2bin(h, 16)' - '0');
w_bits = logical(dec2bin(w, 16)' - '0');
img_bits = bin_img(:)';
payload = [num_bits, h_bits, w_bits, img_bits];
```

- 使用二进制序列拼接 `num`、尺寸信息、图像内容；
- 构建完整的数据流，便于还原。

这是**最核心的升级**，体现了“信息编码 + 信息打包 + LSB 嵌入”的思维方式。



**提取函数部分**：`AdvancedExtract`

提取方式从“盲提取”到“有结构解析”

上一个实验没有结构，直接还原，而在`AdvancedExtract`中：

```matlab
bits_stream = bitget(watermarked(:), 1)';
num_bits = bits_stream(1:32);
h_bits = bits_stream(33:48);
w_bits = bits_stream(49:64);
img_data = bits_stream(65:...);
```

按顺序提取学号 → 尺寸信息 → 图像内容，恢复结构化信息。

```matlab
secret_num = bin2dec(char(num_bits + '0'));
```

将隐藏在图像前部的整数数值还原出来。

------

**自适应图像尺寸重建：**

```matlab
if h*w ~= length(bits_stream(65:end))
    h = orig_size(1);
    w = orig_size(2);
end
```

防止提取图像尺寸出错导致 reshape 报错，提高鲁棒性。



#### 【实验结果】

载体原图像：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421170132408.png" alt="image-20250421170132408" style="zoom: 67%;" />

执行嵌入后的水印图像：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421170441741.png" alt="image-20250421170441741" style="zoom:80%;" />

提取隐藏信息：

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250422083711334.png" alt="image-20250422083711334" style="zoom:67%;" />

<img src="C:\Users\DELL\AppData\Roaming\Typora\typora-user-images\image-20250421171847848.png" alt="image-20250421171847848" style="zoom:67%;" />







## 四、实验总结

本实验通过基于LSB（最低有效位）的图像隐写技术，最终实现了将数字和图像信息同时嵌入到载体图像中的功能，并通过改进算法解决了尺寸解析异常、图像旋转等问题。实验核心流程如下：

1. **数据预处理**：将秘密数字转为32位二进制，二值图像转为行向量，并添加16位高度/宽度头信息。
2. **LSB嵌入**：将混合数据流按序替换载体图像的LSB层，生成含水印图像。
3. **信息提取**：解析LSB流，分离数字和图像数据，动态校验尺寸头信息，最终重构秘密内容。
4. **质量评估**：通过PSNR（>48 dB）验证隐写的不可感知性，确保视觉无差异。

实验结果证明，改进后的算法能实现将数字和图像信息嵌入到二值图中，并能准确提取隐藏信息。
