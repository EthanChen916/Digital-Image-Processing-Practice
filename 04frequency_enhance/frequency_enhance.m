clc;
clear all;

I = imread('orig_chest_xray.tif');
figure(2), imshow(I); title('原始图像');

[height, width] = size(I);

I = double(I);
F = fft2(I);        % 傅里叶变换
F1 = fftshift(F);   % 频谱中心化


D0 = 0.05 * height;  % 截止频率为5%的图像高度
Hp =hpfilter('gaussian', height, width, D0);       % 高斯高通滤波器
%N = 2;               % 滤波器阶数为2
%Hp =hpfilter('butterworth', height, width, D0, N); % 巴特沃斯高通滤波器

F2 = Hp.*F1;
I2 = ifft2d(F2);    % 傅里叶逆变换 
subplot(1, 3, 1), imshow(I2); title('高斯高通滤波');

Hp2 = 0.5 + 2 .* Hp;	% 高频提升加强
F3 = Hp2 .* F1;
I3 = ifft2d(F3); 
subplot(1, 3, 2), imshow(I3); title('高频增强滤波');

I4 = histeq(I3, 256);	% 直方图均衡化
subplot(1, 3, 3), imshow(I4); title('直方图均衡化');


function H = hpfilter(type, height, width, D0, N)
% 创建高通滤波器
    m = round(height / 2);
    n = round(width / 2);

    for i = 1 : height
       for j = 1 : width
            D(i, j) = sqrt((i - m)^2 + (j - n)^2);
       end
    end

    switch type
        case 'ideal'
           H = double(D >= D0);
        case 'butterworth'
           if nargin == 4
               N = 1;	
           end
           H = 1./(1 + (D0./D).^(2 * N));
        case 'gaussian'
           H = 1 - exp(-(D.^2)./(2 * (D0^2)));
        otherwise
            error('Unknown filter type.')
    end

end


function I = ifft2d(F)
% 计算傅里叶逆变换
    F = ifftshift(F);   % 频谱反中心化
    I = ifft2(F);       % 傅里叶反变换
    I = uint8(real(I)); % 取幅值并转换成8位无符号整数
end


