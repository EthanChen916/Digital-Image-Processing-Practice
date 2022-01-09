#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>  

using namespace std;
using namespace cv;

//ƴ��ͼ���Ա���һ��������ʾ
void MergeImg(Mat& dst, Mat& src1, Mat& src2)
{
	int rows = max(src1.rows, src2.rows);
	int cols = src1.cols + 5 + src2.cols;
	CV_Assert(src1.type() == src2.type());
	dst.create(rows, cols, src1.type());
	src1.copyTo(dst(Rect(0, 0, src1.cols, src1.rows)));
	src2.copyTo(dst(Rect(src1.cols + 5, 0, src2.cols, src2.rows)));
}

int main(int argc, char** argv[])
{
	//ת���ɻҶ�ͼ����
	Mat srcImage = imread("./fractured_spine.tif", IMREAD_GRAYSCALE);
	if (srcImage.empty())
	{
		cout << "Error: ��ͼƬʧ��,����!" << endl;
		return -1;
	}

	Mat tempImage, dstImage;

	//����ĻҶ�ֵ��Χѹ��Ϊ[0, 1]
	srcImage.convertTo(tempImage, CV_64F, 1.0 / 255, 0);

	//٤��任
	double gamma = 0.6;  //0.3��0.6��0.9
	pow(tempImage, gamma, dstImage);

	//�Ҷ�ֵ��Χ�ָ���[0, 255]
	dstImage.convertTo(dstImage, CV_8U, 255, 0);

	namedWindow("ԭʼͼ��", WINDOW_AUTOSIZE);
	imshow("ԭʼͼ��", srcImage);
	namedWindow("٤��任ͼ����ǿЧ��", WINDOW_AUTOSIZE);
	imshow("٤��任ͼ����ǿЧ��", dstImage);


	//��һ��������ʾ����ͼ��
	Mat showImg;
	MergeImg(showImg, srcImage, dstImage);  //ƴ��ͼ��

	waitKey(0);
	destroyAllWindows();

	return 0;
}