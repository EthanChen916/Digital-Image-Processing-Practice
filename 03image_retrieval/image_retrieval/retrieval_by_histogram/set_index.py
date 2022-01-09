# USAGE
# python set_index.py --dataset dataset --index index.csv

from pyimageretrieval.color_descriptor import ColorDescriptor
import argparse
import glob
import cv2
import numpy as np


def set_index(args, descriptor):
    # open the output index file for writing
    output = open(args.index, "w")

    # use glob to grab the image paths and loop over them
    for imagePath in glob.glob(args.dataset + "/*.jpg"):
        # extract the image ID (i.e. the unique filename) from the image
        # path and load the image itself
        imageID = imagePath[imagePath.rfind("\\") + 1:]
        # image = cv2.imread(imagePath)
        image = cv2.imdecode(np.fromfile(imagePath, dtype=np.uint8), -1)  # 读取包含中文路径的图片
        # describe the image
        if image.ndim == 3:
            features = descriptor.describe(image)
            print(imageID)

            # write the features to file
            features = [str(f) for f in features]
            output.write("%s,%s\n" % (imageID, ",".join(features)))

    # close the index file
    output.close()


if __name__ == '__main__':
    # construct the argument parser and parse the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--dataset", default='../images',
                        help="Path to the directory that contains the images to be indexed")
    parser.add_argument("-i", "--index", default='./index.csv',
                        help="Path to where the computed index will be stored")
    # args = vars(parser.parse_args())
    args = parser.parse_args()

    # initialize the color descriptor
    descriptor = ColorDescriptor((16, 24, 6))

    set_index(args, descriptor)

