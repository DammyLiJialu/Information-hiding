function main()
    original = imread('original_binary.bmp');

    figure; imshow(original); title('原图像');
    
    % 将文本转换为二进制矩阵
    text = '2211985';
    secret = textToBinaryMatrix(text);
    [m, n] = size(secret);
    
    % 隐藏秘密文本
    original_with_secret = hideSecret(original, m, n, secret);

    figure; imshow(original_with_secret); title('含密图像');

    imwrite(original_with_secret, './pic8/original_with_secret.bmp');
    


    % 提取秘密文本
    secret_extracted = extractSecret(original_with_secret, m, n);
    
    % 将提取的二进制矩阵转换为文本
    decodedText = binaryMatrixToText(secret_extracted);
    disp(['Decoded Text: ', decodedText]);
end

function secret = textToBinaryMatrix(text)
    secret = zeros(length(text), 8);
    for i = 1:length(text)
        binStr = dec2bin(uint8(text(i)), 8); 
        secret(i,:) = binStr - '0';
    end
end

function decodedText = binaryMatrixToText(binaryMatrix)
    [m, ~] = size(binaryMatrix);
    decodedText = blanks(m);
    for i = 1:m
        binChar = num2str(binaryMatrix(i,:));
        binChar = binChar(binChar ~= ' ');
        decodedText(i) = char(bin2dec(binChar));
    end
end

function result = extractSecret(originalWithSecret, m, n)
    result = zeros(m, n);
    for i = 1:m
        for j = 1:n
            blackCount = countBlackPixels(originalWithSecret, i, j);
            result(i, j) = ~(blackCount == 1 || blackCount == 3 || blackCount == 4);
        end
    end
end

% 以下嵌入相关函数保持不变
function result = hideSecret(imageMatrix, numRows, numCols, secretMatrix)
    for i = 1:numRows
        for j = 1:numCols
            blackCount = countBlackPixels(imageMatrix, i, j);
            if secretMatrix(i, j) == 0
                imageMatrix = setPixelsToZero(imageMatrix, i, j, blackCount);
            else
                imageMatrix = setPixelsToOne(imageMatrix, i, j, blackCount);
            end
        end
    end
    result = imageMatrix;
end

function blackCount = countBlackPixels(imageMatrix, row, col) 
    [~, n] = size(imageMatrix);
    halfWidth = n / 2;
    positionInRow = (row - 1) * halfWidth + col;
    positionInMatrix = positionInRow * 4 - 3;
    matrixRow = ceil(double(positionInMatrix) / n);
    matrixCol = positionInMatrix - (matrixRow - 1) * n;

    if matrixCol + 3 > n
        blackCount = 0;
        return;
    end

    blackCount = sum(imageMatrix(matrixRow, matrixCol:(matrixCol + 3)) == 0);
end

function result = setPixelsToZero(imageMatrix, row, col, blackCount)
    [~, n] = size(imageMatrix);
    halfWidth = n / 2;
    positionInRow = (row - 1) * halfWidth + col;
    positionInMatrix = positionInRow * 4 - 3;
    matrixRow = ceil(double(positionInMatrix) / n);
    matrixCol = positionInMatrix - (matrixRow - 1) * n;

    if blackCount == 1 || blackCount == 2 || blackCount == 4
        randIndices = randperm(4, 2);
        imageMatrix(matrixRow, matrixCol + randIndices - 1) = 0;
    elseif blackCount == 0
        imageMatrix(matrixRow, matrixCol + randi(4) - 1) = 0;
    end
    
    result = imageMatrix;
end

function result = setPixelsToOne(imageMatrix, row, col, blackCount)
    [~, n] = size(imageMatrix);
    halfWidth = n / 2;
    positionInRow = (row - 1) * halfWidth + col;
    positionInMatrix = positionInRow * 4 - 3;
    matrixRow = ceil(double(positionInMatrix) / n);
    matrixCol = positionInMatrix - (matrixRow - 1) * n;

    if blackCount == 0
        imageMatrix(matrixRow, matrixCol + randi(4) - 1) = 1;
    elseif blackCount == 2 || blackCount == 3
        randIndices = randperm(4, 2);
        imageMatrix(matrixRow, matrixCol + randIndices - 1) = 1;
    end
    
    result = imageMatrix;
end