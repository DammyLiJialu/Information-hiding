% 读取原始音频文件
[input_signal, fs] = audioread('orign.wav');
input_signal = mean(input_signal, 2);  % 转为单声道
input_signal = input_signal / max(abs(input_signal));  % 归一化

% 嵌入参数设置
bit_sequence = [1 0 1 1 0 1 0 0 1 1];  % 要隐藏的二进制信息
d0 = 50;    % 比特0的延迟样本数（约1.13ms@44.1kHz）
d1 = 100;   % 比特1的延迟样本数（约2.27ms@44.1kHz）
alpha = 0.3;  % 回声衰减系数
frame_length = 1024;  % 每帧样本数

% 计算需要处理的音频长度
num_bits = length(bit_sequence);
required_length = num_bits * frame_length;

% 调整音频长度
if length(input_signal) < required_length
    padded_signal = [input_signal; zeros(required_length - length(input_signal), 1)];
else
    padded_signal = input_signal(1:required_length);
end

% 分帧处理
frames = reshape(padded_signal, frame_length, num_bits)';
output_frames = zeros(num_bits, frame_length);

% 回声隐藏处理
for i = 1:num_bits
    current_frame = frames(i, :)';
    current_bit = bit_sequence(i);
    
    % 创建延迟回声
    echo_signal = zeros(size(current_frame));
    delay = d0*(current_bit==0) + d1*(current_bit==1);
    
    if delay > 0
        echo_signal(delay+1:end) = alpha * current_frame(1:end-delay);
    end
    
    % 合成信号
    output_frames(i, :) = (current_frame + echo_signal)';
end

% 合并所有帧并归一化
output_signal = reshape(output_frames', [], 1);
output_signal = output_signal / max(abs(output_signal));

% 保存带隐藏信息的音频
audiowrite('hidden_message.wav', output_signal, fs);
disp('回声信息隐藏完成！');