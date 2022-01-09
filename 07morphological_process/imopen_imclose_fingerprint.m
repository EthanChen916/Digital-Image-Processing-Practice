clc
clear all

f = imread('noisy_fingerprint.tif');
se = strel('square', 3);  % 结构元素
% se = strel('disk', 2);  % 结构元素 圆盘形

subplot(2,3,1),imshow(f)  % 原始图
title('(a)原始图像')

A = imerode(f, se); % 腐蚀
subplot(2,3,2),imshow(A)
title('(b)腐蚀后的图像')

fo = imopen(f, se);
subplot(2,3,3),imshow(fo)    % 开
title('(c)开操作后的图像')

fc = imclose(f, se);   % 闭
subplot(2,3,4),imshow(fc)
title('(d)闭操作后的图像')

foc = imclose(fo, se);  % 先开再闭
subplot(2,3,5),imshow(foc)
title('(e)先开操作再闭操作后的图像')

fco = imopen(fc, se);   % 先闭再开
subplot(2,3,6),imshow(fco)
title('(f)先闭操作再开操作后的图像')


D = imdilate(fo, se); % 先开再膨胀
subplot(2,3,5),imshow(D)
title('(e)先开再膨胀后的图像')
 
fde = imerode(D, se); % 先开再膨胀再腐蚀 = 先开后闭
subplot(2,3,6),imshow(fde)
title('(f)先开再膨胀再腐蚀后的图像')
