# import all library needed
# pip install BeautifulSoup
import requests
import os
from bs4 import BeautifulSoup

# initiate an image counter
x = 0
# create an array for all similiar image searches
# Each search is likey to download 40 images
# for example if searching dogs, search terms can be "black+dog","white+dog","dog+at+home" etc

search_term = ["black+dogs", "white+dog", "dog+at+home"]
# image folder
folder = "dog"
# looping through all the search terms
for i in range(0, search_term.__len__()):
    # create an array for all the search engines
    url = [
        f"https://www.bing.com/images/search?q={search_term[i]}&go=Search&qs=ds&form=QBIR&first=1&scenario=ImageBasicHover&cw=1901&ch=961"]
    # looping through all urls
    for j in range(0, url.__len__()):
        # using get method to get html code
        html = requests.get(url[j])

        # check if request was successful
        if html.status_code == 200:
            print("request was successful")
        else:
            print(f"something happened with url:{url[j]}")
            # parsing html content using Beautifulsup object
        src = html.content
        soup = BeautifulSoup(src, "lxml")
        # searching img tags
        links = soup.find_all('img')

        # using os to create image folder
        try:
            os.mkdir(folder)
        except FileExistsError:
            print('folder exits')
        # looping though all img tags array and getting the src url
        for link in links:
            imageLink = link.get("src")

            # try to download the image using the built in open method
            try:
                print(x, "downloading.......... at", imageLink)
                r = requests.get(imageLink)
                open(f'{folder}/img{x}.jpg', 'wb').write(r.content)
                # increase counter by 1 after every successful image download
                x += 1
            except Exception:
                print("source an invalid image link")

