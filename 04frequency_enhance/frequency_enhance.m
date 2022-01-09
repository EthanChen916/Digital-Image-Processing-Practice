clc;
clear all;

I = imread('orig_chest_xray.tif');
figure(2), imshow(I); title('ԭʼͼ��');

[height, width] = size(I);

I = double(I);
F = fft2(I);        % ����Ҷ�任
F1 = fftshift(F);   % Ƶ�����Ļ�


D0 = 0.05 * height;  % ��ֹƵ��Ϊ5%��ͼ��߶�
Hp =hpfilter('gaussian', height, width, D0);       % ��˹��ͨ�˲���
%N = 2;               % �˲�������Ϊ2
%Hp =hpfilter('butterworth', height, width, D0, N); % ������˹��ͨ�˲���

F2 = Hp.*F1;
I2 = ifft2d(F2);    % ����Ҷ��任 
subplot(1, 3, 1), imshow(I2); title('��˹��ͨ�˲�');

Hp2 = 0.5 + 2 .* Hp;	% ��Ƶ������ǿ
F3 = Hp2 .* F1;
I3 = ifft2d(F3); 
subplot(1, 3, 2), imshow(I3); title('��Ƶ��ǿ�˲�');

I4 = histeq(I3, 256);	% ֱ��ͼ���⻯
subplot(1, 3, 3), imshow(I4); title('ֱ��ͼ���⻯');


function H = hpfilter(type, height, width, D0, N)
% ������ͨ�˲���
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
% ���㸵��Ҷ��任
    F = ifftshift(F);   % Ƶ�׷����Ļ�
    I = ifft2(F);       % ����Ҷ���任
    I = uint8(real(I)); % ȡ��ֵ��ת����8λ�޷�������
end


