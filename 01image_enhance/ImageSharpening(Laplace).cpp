#include <iostream> 
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>      
#include <opencv2/imgproc.hpp>  

using namespace std;
using namespace cv;

int main(int argc, char* argv[])
{
    Mat srcImage = imread("../images/blurry_moon.tif", IMREAD_GRAYSCALE);
    if (srcImage.empty())
    {
        cout << "Error: 打开图片失败,请检查!" << endl;
        return -1;
    }
    namedWindow("原始图像", WINDOW_AUTOSIZE);
    imshow("原始图像", srcImage);
    
    Mat imageFiltered;
    Mat kernel = (Mat_<float>(3, 3) << 
                                    0, 1, 0, 
                                    1, -4, 1, 
                                    0, 1, 0);  //定义拉普拉斯滤波器模板
    filter2D(srcImage, imageFiltered, CV_8UC1, kernel);  //滤波

    //convertScaleAbs(imageFiltered, imageFiltered);
    namedWindow("未标定的拉普拉斯滤波后的图像", WINDOW_AUTOSIZE);
    imshow("未标定的拉普拉斯滤波后的图像", imageFiltered);
    //Laplacian(srcImage, imageFiltered, CV_16S, 1);

    //标定拉普拉斯滤波的图像
    Mat imageFilteredCal;
    filter2D(srcImage, imageFilteredCal, CV_16SC1, kernel);  //滤波
    double minVal = 0.0;
    double maxVal = 0.0;
    minMaxLoc(imageFilteredCal, &minVal, &maxVal);
    imageFilteredCal = imageFilteredCal - minVal;

    minMaxLoc(imageFilteredCal, &minVal, &maxVal);
    imageFilteredCal = 255 * imageFilteredCal / maxVal;

    convertScaleAbs(imageFilteredCal, imageFilteredCal);    //CV_16S->CV_8U
    namedWindow("标定的拉普拉斯滤波后的图像", WINDOW_AUTOSIZE);
    imshow("标定的拉普拉斯滤波后的图像", imageFilteredCal);

    //图像锐化
    Mat dstImage = srcImage - imageFiltered;  //锐化后的图像
    //convertScaleAbs(dstImage, dstImage);

    namedWindow("拉普拉斯算子图像增强效果", WINDOW_AUTOSIZE);
    imshow("拉普拉斯算子图像增强效果", dstImage);

    waitKey(0);
    destroyAllWindows();

    return 0;
}
