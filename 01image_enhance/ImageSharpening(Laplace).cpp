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
        cout << "Error: ��ͼƬʧ��,����!" << endl;
        return -1;
    }
    namedWindow("ԭʼͼ��", WINDOW_AUTOSIZE);
    imshow("ԭʼͼ��", srcImage);
    
    Mat imageFiltered;
    Mat kernel = (Mat_<float>(3, 3) << 
                                    0, 1, 0, 
                                    1, -4, 1, 
                                    0, 1, 0);  //����������˹�˲���ģ��
    filter2D(srcImage, imageFiltered, CV_8UC1, kernel);  //�˲�

    //convertScaleAbs(imageFiltered, imageFiltered);
    namedWindow("δ�궨��������˹�˲����ͼ��", WINDOW_AUTOSIZE);
    imshow("δ�궨��������˹�˲����ͼ��", imageFiltered);
    //Laplacian(srcImage, imageFiltered, CV_16S, 1);

    //�궨������˹�˲���ͼ��
    Mat imageFilteredCal;
    filter2D(srcImage, imageFilteredCal, CV_16SC1, kernel);  //�˲�
    double minVal = 0.0;
    double maxVal = 0.0;
    minMaxLoc(imageFilteredCal, &minVal, &maxVal);
    imageFilteredCal = imageFilteredCal - minVal;

    minMaxLoc(imageFilteredCal, &minVal, &maxVal);
    imageFilteredCal = 255 * imageFilteredCal / maxVal;

    convertScaleAbs(imageFilteredCal, imageFilteredCal);    //CV_16S->CV_8U
    namedWindow("�궨��������˹�˲����ͼ��", WINDOW_AUTOSIZE);
    imshow("�궨��������˹�˲����ͼ��", imageFilteredCal);

    //ͼ����
    Mat dstImage = srcImage - imageFiltered;  //�񻯺��ͼ��
    //convertScaleAbs(dstImage, dstImage);

    namedWindow("������˹����ͼ����ǿЧ��", WINDOW_AUTOSIZE);
    imshow("������˹����ͼ����ǿЧ��", dstImage);

    waitKey(0);
    destroyAllWindows();

    return 0;
}
