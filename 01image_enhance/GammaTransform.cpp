#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>  

using namespace std;
using namespace cv;

//拼接图像，以便在一个窗口显示
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
	//转换成灰度图读入
	Mat srcImage = imread("./fractured_spine.tif", IMREAD_GRAYSCALE);
	if (srcImage.empty())
	{
		cout << "Error: 打开图片失败,请检查!" << endl;
		return -1;
	}

	Mat tempImage, dstImage;

	//输入的灰度值范围压缩为[0, 1]
	srcImage.convertTo(tempImage, CV_64F, 1.0 / 255, 0);

	//伽马变换
	double gamma = 0.6;  //0.3、0.6、0.9
	pow(tempImage, gamma, dstImage);

	//灰度值范围恢复到[0, 255]
	dstImage.convertTo(dstImage, CV_8U, 255, 0);

	namedWindow("原始图像", WINDOW_AUTOSIZE);
	imshow("原始图像", srcImage);
	namedWindow("伽马变换图像增强效果", WINDOW_AUTOSIZE);
	imshow("伽马变换图像增强效果", dstImage);


	//在一个窗口显示两幅图像
	Mat showImg;
	MergeImg(showImg, srcImage, dstImage);  //拼接图像

	waitKey(0);
	destroyAllWindows();

	return 0;
}