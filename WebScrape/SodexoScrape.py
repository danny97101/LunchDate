
# @author  Timothy Marotta
# @date    April 18, 2019
# @purpose Scrape food information from Sodexo Webpage

from urllib.request import *
from urllib.error import HTTPError
from bs4 import BeautifulSoup
import datetime


def format_array(dh, array):
    if dh == 0:
        array.remove('LUNCH')
        array.remove('Chef Table')
        array.remove('Deli')
        array.remove('Food Lab')
        array.remove('Pizza')
        array.remove('Simple Servings')
        array.remove('Soups')
        return array
    elif dh == 1:
        array.remove('LUNCH')
        array.remove('Deli')
        array.remove('Entrées')
        array.remove('Grill')
        array.remove('International')
        array.remove('Pizza')
        array.remove('Simple Servings')
        array.remove('Soups')
        array.remove('Vegan')
        return array
    elif dh == 2:
        array.remove('LUNCH')
        array.remove('Basil')
        array.remove('Chef\'s Table')
        array.remove('Daily Dish')
        array.remove('Ignite')
        return array
    else:
        print("Format unrecognized. Try again.")


def scrape_soup(dh, scraped, url):
    html = urlopen(url).read().decode('UTF-8')
    soup = BeautifulSoup(html, 'html.parser')
    day = datetime.datetime.today().day
    menu = soup.find_all('div', id="menuid-"+str(day)+"-day")[-1].get_text("|", strip=True)
    spliced = menu.split("|")

    lunch_start = spliced.index('LUNCH')
    lunch_end = spliced.index('DINNER')
    display(format_array(dh, spliced[lunch_start:lunch_end]))


def display(scraped):
    for x in range(0, len(scraped), 2):
        print(str(scraped[x])+'\t'+str(scraped[x+1]))


def main():
    campus_center = []
    towers = []
    terraces = []
    print("----------terraces----------")
    scrape_soup(0, terraces, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
    print("\n----------campus center----------")
    scrape_soup(1, campus_center, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
    print("\n----------towers----------")
    scrape_soup(2, towers, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")


main()
