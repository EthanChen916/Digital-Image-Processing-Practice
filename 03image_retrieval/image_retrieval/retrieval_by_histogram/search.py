# USAGE
# python search.py -i index.csv -q queries/103100.png -r dataset

from pyimageretrieval.color_descriptor import ColorDescriptor
from pyimageretrieval.searcher import Searcher
import argparse
from pylab import *
from PIL import Image
from matplotlib.font_manager import FontProperties
import cv2


def retrieval(args, descriptor):
    font = FontProperties(size=10)

    # load the query image and describe it
    # query = cv2.imread(args.query)
    query = cv2.imdecode(np.fromfile(args.query, dtype=np.uint8), -1)  # 读取包含中文路径的图片
    features = descriptor.describe(query)

    # perform the search
    searcher = Searcher(args.index)
    results = searcher.search(features, limit=5)  # 显示的图片数量

    gray()
    plt.subplots_adjust(hspace=0.03, wspace=0.03)
    subplot(2, 5, 3)
    title(u'Src', fontproperties=font)
    imshow(query[:, :, ::-1])
    axis('off')

    i = 0
    for (dis, rI) in results:
        img = Image.open(args.result_path + "/" + rI)
        gray()
        i = i + 1
        subplot(2, 5, i + 5)
        dis = round(dis, 3)
        s = str(dis)
        title(s, fontproperties=font)
        imshow(img)
        axis('off')
    show()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--index", default='./index.csv',
                        help="Path to where the computed index will be stored")
    parser.add_argument('-q', '--query', default='./queries/100000.png', type=str,
                        help='the location of the query image')
    parser.add_argument("-r", "--result-path", default='../images',
                        help="Path to the result path")
    # args = vars(parser.parse_args())
    args = parser.parse_args()
    # initialize the image descriptor
    descriptor = ColorDescriptor((16, 24, 6))

    retrieval(args, descriptor)
