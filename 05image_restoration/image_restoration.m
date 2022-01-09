clc;
clear all;

I = imread('applo17_boulder_noisy.tif');
% I = imread('source_image.jpg');
% I = rgb2gray(I);
subplot(1, 4, 1),  imshow(I); title('原始图像');

[height, width] = size(I);

I = double(I);
F = fft2(I);        % 傅里叶变换
F1 = fftshift(F);   % 频谱中心化

F2 = log(abs(F1));   % 压缩F1的幅值范围，便于显示
subplot(1, 4, 2), imshow(F2, []); title('原始频谱'); 


D0 = 150;  % 频带中心半径
N = 4;               % 滤波器阶数为4
W = 300;
Hp =bsfilter('gaussian', height, width, D0, W);       % 高斯带阻滤波器

%Hp =bsfilter('butterworth', height, width, D0, W, N); % 巴特沃斯带阻滤波器

F2 = Hp.*F1;
I2 = ifft2d(F2);    % 傅里叶逆变换 
subplot(1, 4, 3), imshow(I2); title('巴特沃斯带阻滤波');

F2 = log(abs(F2));   % 压缩F2的幅值范围，便于显示
subplot(1, 4, 4), imshow(F2, []); title('滤波后的频谱'); 


[h w]=size(I2);
imgn=imresize(I2,[floor(h/2) floor(w/2)]);
imgn=imresize(imgn,[h w]);
img=double(I2);
imgn=double(imgn);
 
B=8;                %编码一个像素用多少二进制位
MAX=2^B-1;          %图像有多少灰度级
MES=sum(sum((img-imgn).^2))/(h*w);     %均方差
PSNR=20*log10(MAX/sqrt(MES));           %峰值信噪比

function H = bsfilter(type, height, width, D0, W, N)
% 创建带阻滤波器
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
           temp = (D.*W)./((D.^2 - D0^2));
           H = 1./(1 + temp.^(2 * N));
        case 'gaussian'
           temp = -1/2.*((D.^2 - D0^2)./(D.*W)).^2;
           H = 1 - exp(temp);
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


