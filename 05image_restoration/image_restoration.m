clc;
clear all;

I = imread('applo17_boulder_noisy.tif');
% I = imread('source_image.jpg');
% I = rgb2gray(I);
subplot(1, 4, 1),  imshow(I); title('ԭʼͼ��');

[height, width] = size(I);

I = double(I);
F = fft2(I);        % ����Ҷ�任
F1 = fftshift(F);   % Ƶ�����Ļ�

F2 = log(abs(F1));   % ѹ��F1�ķ�ֵ��Χ��������ʾ
subplot(1, 4, 2), imshow(F2, []); title('ԭʼƵ��'); 


D0 = 150;  % Ƶ�����İ뾶
N = 4;               % �˲�������Ϊ4
W = 300;
Hp =bsfilter('gaussian', height, width, D0, W);       % ��˹�����˲���

%Hp =bsfilter('butterworth', height, width, D0, W, N); % ������˹�����˲���

F2 = Hp.*F1;
I2 = ifft2d(F2);    % ����Ҷ��任 
subplot(1, 4, 3), imshow(I2); title('������˹�����˲�');

F2 = log(abs(F2));   % ѹ��F2�ķ�ֵ��Χ��������ʾ
subplot(1, 4, 4), imshow(F2, []); title('�˲����Ƶ��'); 


[h w]=size(I2);
imgn=imresize(I2,[floor(h/2) floor(w/2)]);
imgn=imresize(imgn,[h w]);
img=double(I2);
imgn=double(imgn);
 
B=8;                %����һ�������ö��ٶ�����λ
MAX=2^B-1;          %ͼ���ж��ٻҶȼ�
MES=sum(sum((img-imgn).^2))/(h*w);     %������
PSNR=20*log10(MAX/sqrt(MES));           %��ֵ�����

function H = bsfilter(type, height, width, D0, W, N)
% ���������˲���
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
% ���㸵��Ҷ��任
    F = ifftshift(F);   % Ƶ�׷����Ļ�
    I = ifft2(F);       % ����Ҷ���任
    I = uint8(real(I)); % ȡ��ֵ��ת����8λ�޷�������
end


