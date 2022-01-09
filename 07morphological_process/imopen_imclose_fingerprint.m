clc
clear all

f = imread('noisy_fingerprint.tif');
se = strel('square', 3);  % �ṹԪ��
% se = strel('disk', 2);  % �ṹԪ�� Բ����

subplot(2,3,1),imshow(f)  % ԭʼͼ
title('(a)ԭʼͼ��')

A = imerode(f, se); % ��ʴ
subplot(2,3,2),imshow(A)
title('(b)��ʴ���ͼ��')

fo = imopen(f, se);
subplot(2,3,3),imshow(fo)    % ��
title('(c)���������ͼ��')

fc = imclose(f, se);   % ��
subplot(2,3,4),imshow(fc)
title('(d)�ղ������ͼ��')

foc = imclose(fo, se);  % �ȿ��ٱ�
subplot(2,3,5),imshow(foc)
title('(e)�ȿ������ٱղ������ͼ��')

fco = imopen(fc, se);   % �ȱ��ٿ�
subplot(2,3,6),imshow(fco)
title('(f)�ȱղ����ٿ��������ͼ��')


D = imdilate(fo, se); % �ȿ�������
subplot(2,3,5),imshow(D)
title('(e)�ȿ������ͺ��ͼ��')
 
fde = imerode(D, se); % �ȿ��������ٸ�ʴ = �ȿ����
subplot(2,3,6),imshow(fde)
title('(f)�ȿ��������ٸ�ʴ���ͼ��')
