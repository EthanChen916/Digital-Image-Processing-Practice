# -*- coding: utf-8 -*-
import pickle
from PCV.localdescriptors import sift
from PCV.imagesearch import imagesearch
from PCV.geometry import homography
from PCV.tools.imtools import get_imlist


# 载入图像列表
imlist = get_imlist('../images/')
nbr_images = len(imlist)

# 载入特征列表
featlist = [imlist[i][:-3]+'sift' for i in range(nbr_images)]

# 载入词汇
with open('../images/vocabulary.pkl', 'rb') as f:
    voc = pickle.load(f)

src = imagesearch.Searcher('../images/testImaAdd.db', voc)

# 查询图像索引和查询返回的图像数
q_ind = 3
nbr_results = 4

# 常规查询(按欧式距离对结果排序)
res_reg = [w[1] for w in src.query(imlist[q_ind])[:nbr_results]]
print('top matches (regular):', res_reg)

# 载入查询图像特征
q_locs, q_descr = sift.read_features_from_file(featlist[q_ind])
fp = homography.make_homog(q_locs[:,:2].T)

# 用单应性进行拟合建立RANSAC模型
model = homography.RansacModel()
rank = {}

# 载入候选图像的特征
for ndx in res_reg[1:]:
    locs, descr = sift.read_features_from_file(featlist[ndx])  # because 'ndx' is a rowid of the DB that starts at 1
    # get matches
    matches = sift.match(q_descr,descr)
    ind = matches.nonzero()[0]
    ind2 = matches[ind]
    tp = homography.make_homog(locs[:,:2].T)
    # compute homography, count inliers. if not enough matches return empty list
    try:
        H,inliers = homography.H_from_ransac(fp[:,ind],tp[:,ind2],model,match_theshold=4)
    except:
        inliers = []
    # store inlier count
    rank[ndx] = len(inliers)

# sort dictionary to get the most inliers first
sorted_rank = sorted(rank.items(), key=lambda t: t[1], reverse=True)
res_geom = [res_reg[0]]+[s[0] for s in sorted_rank]
print('top matches (homography):', res_geom)

# 显示查询结果
imagesearch.plot_results(src, res_reg[:8])  # 常规查询
imagesearch.plot_results(src, res_geom[:8])  # 重排后的结果

