#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cuda.h>
#include <device_functions.h>
#include <opencv2\opencv.hpp>
#include <iostream>
#include "time.h"

using namespace std;
using namespace cv;


//Sobel���ӱ�Ե���˺���
__global__ void sobelInCuda(unsigned char* dataIn, unsigned char* dataOut, int imgHeight, int imgWidth)
{
    int xIndex = threadIdx.x + blockIdx.x * blockDim.x;
    int yIndex = threadIdx.y + blockIdx.y * blockDim.y;
    int index = yIndex * imgWidth + xIndex;
    float Gx = 0;
    float Gy = 0;

    if (xIndex > 0 && xIndex < imgWidth - 1 && yIndex > 0 && yIndex < imgHeight - 1)
    {
        Gx = dataIn[(yIndex - 1) * imgWidth + xIndex + 1] + 2 * dataIn[yIndex * imgWidth + xIndex + 1] + dataIn[(yIndex + 1) * imgWidth + xIndex + 1]
            - (dataIn[(yIndex - 1) * imgWidth + xIndex - 1] + 2 * dataIn[yIndex * imgWidth + xIndex - 1] + dataIn[(yIndex + 1) * imgWidth + xIndex - 1]);
        Gy = dataIn[(yIndex - 1) * imgWidth + xIndex - 1] + 2 * dataIn[(yIndex - 1) * imgWidth + xIndex] + dataIn[(yIndex - 1) * imgWidth + xIndex + 1]
            - (dataIn[(yIndex + 1) * imgWidth + xIndex - 1] + 2 * dataIn[(yIndex + 1) * imgWidth + xIndex] + dataIn[(yIndex + 1) * imgWidth + xIndex + 1]);
        
        if (Gx < 0) Gx = 0;
        if (Gx > 255) Gx = 255;

        if (Gy < 0) Gy = 0;
        if (Gy > 255) Gy = 255;

        dataOut[index] = sqrt(Gx * Gx + Gy * Gy);
    }
}

//Sobel���ӱ�Ե���OpenMP����
void sobelInOpenMP(Mat srcImg, Mat dstImg, int imgHeight, int imgWidth)
{
    float Gx = 0;
    float Gy = 0;
    #pragma omp parallel for private(Gx, Gy)
    for (int i = 1; i < imgHeight - 1; i++)
    {
        uchar* dataUp = srcImg.ptr<uchar>(i - 1);
        uchar* data = srcImg.ptr<uchar>(i);
        uchar* dataDown = srcImg.ptr<uchar>(i + 1);
        uchar* out = dstImg.ptr<uchar>(i);
        for (int j = 1; j < imgWidth - 1; j++)
        {
            Gx = (dataUp[j + 1] + 2 * data[j + 1] + dataDown[j + 1]) - (dataUp[j - 1] + 2 * data[j - 1] + dataDown[j - 1]);
            Gy = (dataUp[j - 1] + 2 * dataUp[j] + dataUp[j + 1]) - (dataDown[j - 1] + 2 * dataDown[j] + dataDown[j + 1]);

            if (Gx < 0) Gx = 0;
            if (Gx > 255) Gx = 255;

            if (Gy < 0) Gy = 0;
            if (Gy > 255) Gy = 255;

            out[j] = sqrt(Gx * Gx + Gy * Gy);
        }
    }
}

//Sobel���ӱ�Ե���CPU����
void sobel(Mat srcImg, Mat dstImg, int imgHeight, int imgWidth)
{
    float Gx = 0;
    float Gy = 0;

    for (int i = 1; i < imgHeight - 1; i++)
    {
        uchar* dataUp = srcImg.ptr<uchar>(i - 1);
        uchar* data = srcImg.ptr<uchar>(i);
        uchar* dataDown = srcImg.ptr<uchar>(i + 1);
        uchar* out = dstImg.ptr<uchar>(i);
        for (int j = 1; j < imgWidth - 1; j++)
        {
            //�����ٶȿ�
            Gx = (dataUp[j + 1] + 2 * data[j + 1] + dataDown[j + 1]) - (dataUp[j - 1] + 2 * data[j - 1] + dataDown[j - 1]);
            Gy = (dataUp[j - 1] + 2 * dataUp[j] + dataUp[j + 1]) - (dataDown[j - 1] + 2 * dataDown[j] + dataDown[j + 1]);
            

            if (Gx < 0) Gx = 0;
            if (Gx > 255) Gx = 255;

            if (Gy < 0) Gy = 0;
            if (Gy > 255) Gy = 255;

            out[j] = sqrt(Gx * Gx + Gy * Gy);
        }
    }
}


int main()
{
    //��ӡGPU����
    cudaDeviceProp prop;

    int count;
    cudaGetDeviceCount(&count);

    for (int i = 0; i < count; i++)
    {
        cudaGetDeviceProperties(&prop, i);
        cout << "the information for the device : " << i << endl;
        cout << "name:" << prop.name << endl;
        cout << "the memory information for the device : " << i << endl;
        cout << "total global memory:" << prop.totalGlobalMem << endl;
        cout << "total constant memory:" << prop.totalConstMem << endl;
        cout << "threads in warps:" << prop.warpSize << endl;
        cout << "max threads per block:" << prop.maxThreadsPerBlock << endl;
        cout << "max threads dims:" << prop.maxThreadsDim[0] << "  " << prop.maxThreadsDim[1] <<
            "  " << prop.maxThreadsDim[2] << endl;
        cout << "max grid dims:" << prop.maxGridSize[0] << "  " <<
            prop.maxGridSize[1] << "  " << prop.maxGridSize[2] << endl;
        cout << endl;
    }


    Mat grayImg = imread("./dog.jpg", 0);

    int imgHeight = grayImg.rows;
    int imgWidth = grayImg.cols;

    Mat gaussImg;
    //��˹�˲�
    GaussianBlur(grayImg, gaussImg, Size(3, 3), 0, 0, BORDER_DEFAULT);

    //Sobel����CPUʵ��
    Mat dst(imgHeight, imgWidth, CV_8UC1, Scalar(0));

    clock_t cpu_start = clock();
    sobel(gaussImg, dst, imgHeight, imgWidth);
    clock_t cpu_finish = clock();
    double cpu_duration = (double)(cpu_finish - cpu_start) / CLOCKS_PER_SEC;
    cout << "CPU run time = " << cpu_duration << "seconds" << endl;

    //Sobel����OpenMPʵ��
    clock_t openmp_start = clock();
    sobelInOpenMP(gaussImg, dst, imgHeight, imgWidth);
    clock_t openmp_finish = clock();
    double openmp_duration = (double)(openmp_finish - openmp_start) / CLOCKS_PER_SEC;
    cout << "OpenMP run time = " << openmp_duration << "seconds" << endl;


    //CUDAʵ�ֺ�Ĵ��ص�ͼ��
    Mat dstImg(imgHeight, imgWidth, CV_8UC1, Scalar(0));

    //����GPU�ڴ�
    unsigned char* d_in;
    unsigned char* d_out;

    cudaMalloc((void**)&d_in, imgHeight * imgWidth * sizeof(unsigned char));
    cudaMalloc((void**)&d_out, imgHeight * imgWidth * sizeof(unsigned char));

    //����˹�˲����ͼ���CPU����GPU
    cudaMemcpy(d_in, gaussImg.data, imgHeight * imgWidth * sizeof(unsigned char), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(32, 32);
    dim3 blocksPerGrid((imgWidth + threadsPerBlock.x - 1) / threadsPerBlock.x, (imgHeight + threadsPerBlock.y - 1) / threadsPerBlock.y);


    double gpu_duration = 0;
    clock_t gpu_start, gpu_finish;
    int cnt = 25;
    for (int i = 0; i < 50; i++)
    {
        gpu_start = clock();
        sobelInCuda <<< blocksPerGrid, threadsPerBlock >>> (d_in, d_out, imgHeight, imgWidth);
        cudaDeviceSynchronize(); // ���ʹ��CPU��ʱ��ʽ��һ��Ҫ��ͬ������
        gpu_finish = clock();
        if(i >= (50 - cnt))
            gpu_duration += (double)(gpu_finish - gpu_start) / CLOCKS_PER_SEC;
    }

    cout << "CUDA run time = " << gpu_duration / cnt << "seconds" << endl;


   /* for (int i = 0; i < 50; i++)
    {
        //ʹ��event����ʱ��
        float elapsedTime;
        cudaEvent_t start, stop;
        cudaEventCreate(&start);    //����Event
        cudaEventCreate(&stop);
        cudaEventRecord(start, 0);    //��¼��ǰʱ��

        //���ú˺���
        sobelInCuda <<< blocksPerGrid, threadsPerBlock >>> (d_in, d_out, imgHeight, imgWidth);

        cudaEventRecord(stop, 0);    //��¼��ǰʱ��
        cudaEventSynchronize(stop);

        cudaEventElapsedTime(&elapsedTime, start, stop);
        cout << "CUDA Run time =" << elapsedTime / 1000 << "seconds" << endl;
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
    }*/


    //��ͼ�񴫻�GPU
    cudaMemcpy(dstImg.data, d_out, imgHeight * imgWidth * sizeof(unsigned char), cudaMemcpyDeviceToHost);

    //�ͷ�GPU�ڴ�
    cudaFree(d_in);
    cudaFree(d_out);


    namedWindow("��Եͼ��", WINDOW_FREERATIO);
    imshow("��Եͼ��", dstImg);

    waitKey(0);
    destroyAllWindows();


    return 0;
}