#include <iostream>

#include <opencv2\opencv.hpp>
#include <opencv2\core.hpp>
#include <opencv2\highgui\highgui.hpp>

#include "time.h"

using namespace std;
using namespace cv;

Mat edgeDetection(Mat img) 
{
    int row = img.rows;
    int col = img.cols;

    Mat G = img.clone();
    int Gx, Gy;

    #pragma omp parallel for private(Gx, Gy)
    for (int i = 1; i < row - 1; i++) {
        for (int j = 1; j < col - 1; j++) {

            Gx = -img.at<uchar>(i - 1, j - 1)
                - img.at<uchar>(i, j - 1) * 2
                - img.at<uchar>(i + 1, j - 1)
                + img.at<uchar>(i - 1, j + 1)
                + img.at<uchar>(i, j + 1) * 2
                + img.at<uchar>(i + 1, j + 1);

            Gy = -img.at<uchar>(i - 1, j - 1)
                - img.at<uchar>(i - 1, j) * 2
                - img.at<uchar>(i - 1, j + 1)
                + img.at<uchar>(i + 1, j - 1)
                + img.at<uchar>(i + 1, j) * 2
                + img.at<uchar>(i + 1, j + 1);


                if (Gx < 0) Gx = 0;
                if (Gx > 255) Gx = 255;

                if (Gy < 0) Gy = 0;
                if (Gy > 255) Gy = 255;

                G.at<uchar>(i, j) = sqrt(Gx * Gx + Gy * Gy);
        }
    }
    return G;
}

Mat edgeDetectionNoParallel(Mat img)
{
    int row = img.rows;
    int col = img.cols;

    Mat G = img.clone();
    int Gx, Gy;

    for (int i = 1; i < row - 1; i++) {            
        for (int j = 1; j < col - 1; j++) {            
            Gx = -img.at<uchar>(i - 1, j - 1)
                - img.at<uchar>(i, j - 1) * 2
                - img.at<uchar>(i + 1, j - 1)
                + img.at<uchar>(i - 1, j + 1)
                + img.at<uchar>(i, j + 1) * 2
                + img.at<uchar>(i + 1, j + 1);

            Gy = -img.at<uchar>(i - 1, j - 1)
                - img.at<uchar>(i - 1, j) * 2
                - img.at<uchar>(i - 1, j + 1)
                + img.at<uchar>(i + 1, j - 1)
                + img.at<uchar>(i + 1, j) * 2
                + img.at<uchar>(i + 1, j + 1);


            if (Gx < 0) Gx = 0;
            if (Gx > 255) Gx = 255;

            if (Gy < 0) Gy = 0;
            if (Gy > 255) Gy = 255;

            G.at<uchar>(i, j) = sqrt(Gx * Gx + Gy * Gy);
        }
    }
    return G;
}

int main()
{
    Mat srcImg, Gx, Gy, Gxy;
    srcImg = imread("./dog.jpg");
	cvtColor(srcImg, srcImg, COLOR_BGR2GRAY); //±äÎª»Ò¶ÈÍ¼Ïñ

    clock_t start = clock();


    int height = srcImg.rows;
    int width = srcImg.cols;

    Gx = srcImg.clone();
    Gy = srcImg.clone();
    Gxy = srcImg.clone();


    Mat dstImg = srcImg.clone();

    dstImg = edgeDetection(srcImg);

    clock_t finish = clock();
    double duration = (double)(finish - start) / CLOCKS_PER_SEC;
    printf("Parallel Run time = %f seconds\n", duration);


    start = clock();
    dstImg = srcImg.clone();

    dstImg = edgeDetectionNoParallel(srcImg);

    finish = clock();
    duration = (double)(finish - start) / CLOCKS_PER_SEC;
    printf("No Parallel Run time = %f seconds\n", duration);


    namedWindow("±ßÔµÍ¼Ïñ", WINDOW_FREERATIO);
    imshow("±ßÔµÍ¼Ïñ", dstImg);

    waitKey(0);
    destroyAllWindows();

	return 0;
}