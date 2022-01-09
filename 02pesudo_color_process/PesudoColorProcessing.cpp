#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>  

using namespace std;
using namespace cv;


int main(int argc, char** argv[])
{
	//转换成灰度图读入
	Mat srcImage = imread("../images/weld-original.tif", IMREAD_GRAYSCALE);
	if (srcImage.empty())
	{
		cout << "Error: 打开图片失败,请检查!" << endl;
		return -1;
	}

	int height = srcImage.rows;
	int width = srcImage.cols;

	Mat dstImage(height, width, CV_8UC3, Scalar(0, 0, 0));

	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		{
			if (srcImage.at<uchar>(i, j) < 255)
			{
				dstImage.at<Vec3b>(i, j)[0] = 255;
			}
			else
			{
				dstImage.at<Vec3b>(i, j)[2] = 255;
			}
		}
	}

	namedWindow("原始图像", WINDOW_AUTOSIZE);
	imshow("原始图像", srcImage);

	namedWindow("伪彩色图像", WINDOW_AUTOSIZE);
	imshow("伪彩色图像", dstImage);

	waitKey(0);
	destroyAllWindows();

	return 0;
}