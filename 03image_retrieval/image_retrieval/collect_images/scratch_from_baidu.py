import requests
import re
from urllib import parse
import os

# keywords = ['马云','李彦宏','马化腾','雷军','刘强东','王兴','汪滔','任正非','周鸿祎','张朝阳']
keywords = ['张一鸣','李彦宏','马化腾','任正非','汪滔']


class BaiduImageSpider(object):
    def __init__(self):
        self.url = 'https://image.baidu.com/search/flip?tn=baiduimage&word={}'
        self.headers = {'User-Agent': 'Mozilla/5.0'}

    # 获取图片
    def get_image(self, url, word):
        # 使用 requests模块得到响应对象
        res = requests.get(url, headers=self.headers)
        # 更改编码格式
        res.encoding = "utf-8"
        # 得到html网页
        html = res.text
        print(html)
        # 正则解析
        pattern = re.compile('"objURL":"(.*?)"', re.S)  # objURL是原图、hoverUrL是鼠标移动过后显示的版本humburl、middlebro是图片缩小的版本
        img_link_list = pattern.findall(html)
        # 存储图片的url链接
        print(img_link_list)

        # 创建目录，用于保存图片
        # directory = '../images/{}/'.format(word)
        directory = '../images/'
        # 如果目录不存在则创建
        if not os.path.exists(directory):
            os.makedirs(directory)

        # 下载图片
        i = 1
        for img_link in img_link_list:
            try:
                html = requests.get(url=img_link, headers=self.headers, timeout=5)
            except requests.exceptions.ConnectionError:
                print('【错误】当前图片无法下载')
                continue
            # 保存图片
            filename = '{}{}_{}.jpg'.format(directory, word, i)
            with open(filename, 'wb') as f:
                f.write(html.content)
                f.close()
            print(filename, '下载成功')
            i += 1
            if i == 41:
                break

    # 入口函数
    def run(self):
        # word = input("请输入你要下载图片的关键词：")
        for word in keywords:
            word_parse = parse.quote(word)
            url = self.url.format(word_parse)
            self.get_image(url, word)


if __name__ == '__main__':
    spider = BaiduImageSpider()
    spider.run()
