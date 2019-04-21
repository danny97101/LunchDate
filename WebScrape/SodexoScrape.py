
# @author  Timothy Marotta
# @date    April 18, 2019
# @purpose Scrape food information from Sodexo Webpage

from urllib.request import *
from urllib.error import HTTPError
from bs4 import BeautifulSoup
import datetime


def format(array):
    array.remove('LUNCH')
    array.remove('Chef Table')
    array.remove('Deli')
    array.remove('Food Lab')
    array.remove('Pizza')
    array.remove('Simple Servings')
    array.remove('Soups')
    return array

def scrape_soup(scraped, url):
    html = urlopen(url).read().decode('UTF-8')
    soup = BeautifulSoup(html, 'html.parser')
    day = datetime.datetime.today().day
    menu = soup.find_all('div', id="menuid-"+str(day)+"-day")[-1].get_text("|", strip=True)
    spliced = menu.split("|")

    lunch_start = spliced.index('LUNCH')
    lunch_end = spliced.index('DINNER')
    display(format(spliced[lunch_start:lunch_end]))


'''
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
'''


def display(scraped):
    for x in range(0, len(scraped)):
        print(str(scraped[x])+', ')


def main():
    campusCenter = []
    towers = []
    terraces = []
    print("terraces")
    scrape_soup(terraces, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
    # print("campus center")
    #scrape_soup(campusCenter, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
    # print("towers")
    # scrape_soup(towers, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")
    #display(towers)


main()
