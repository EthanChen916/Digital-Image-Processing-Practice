# -*- coding: utf-8 -*-
import os
import pickle
from PCV.imagesearch import imagesearch
from PCV.localdescriptors import sift
import sqlite3
from PCV.tools.imtools import get_imlist

# 获取图像列表
imlist = get_imlist('../images/')
nbr_images = len(imlist)
# 获取特征列表
featlist = [imlist[i][:-3]+'sift' for i in range(nbr_images)]

# 载入词汇
with open('../images/vocabulary.pkl', 'rb') as f:
    voc = pickle.load(f)

# 创建索引
if os.path.exists('../images/testImaAdd.db'):
    os.remove('../images/testImaAdd.db')
indx = imagesearch.Indexer('../images/testImaAdd.db', voc)
indx.create_tables()


# 遍历所有的图像，并将它们的特征投影到词汇上
for i in range(nbr_images)[:100]:
    locs, descr = sift.read_features_from_file(featlist[i])
    indx.add_to_index(imlist[i],descr)

# 提交到数据库
indx.db_commit()

con = sqlite3.connect('../images/testImaAdd.db')
print(con.execute('select count (filename) from imlist').fetchone())
print(con.execute('select * from imlist').fetchone())
