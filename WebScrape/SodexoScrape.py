
#@author  Timothy Marotta
#@date    April 18, 2019
#@purpose Scrape food information from Sodexo Webpage

from urllib.request import *
from urllib.error import HTTPError
from bs4 import BeautifulSoup
import re


def scrapesoup(scraped, url):
    html = urlopen(url).read().decode('UTF-8')

    soup = BeautifulSoup(html, 'html.parser')
    #TODO need to select different div tag based on day, currently works for current - 5
    #select bite date div tag instead, then lunch
    temp = soup.find_all('div', class_="accordion-panel rtf hide")
    print(temp[2])


def scrape(scraped, url):
    try:
        data = urlopen(url)
    except HTTPError as e:
        data = e.read()

    lines = data.readlines()
    for x in range(len(lines)):
        lines[x] = lines[x].decode('utf-8')
        if 'data-foodItemName' in lines[x] and x < 3600:
            loc = lines[x].find("\">")
            loc2 = lines[x].find('</a>')
            line = lines[x][loc + 2:loc2]
            scraped.append(str(x) + ': ' + line)


def display(scraped):
    for x in range(len(scraped)):
        print(scraped[x]+', ')


def main():
    campusCenter = []
    towers = []
    terraces = []
    #scrape(terraces, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
    #scrape(campusCenter, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
    scrapesoup(towers, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")
    #display(towers)


main()
