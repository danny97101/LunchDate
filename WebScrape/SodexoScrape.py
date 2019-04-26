
# @author  Timothy Marotta
# @date    April 18, 2019
# @purpose Scrape food information from Sodexo Webpage
from urllib.request import urlopen
from bs4 import BeautifulSoup
import datetime
import pymysql.cursors
import time


def format_array(dh, array):
    if dh == 0:
        try:
            array.remove('LUNCH')
        except:
            print("LUNCH did not exist")

        try:
            array.remove('Chef Table')
        except:
            print("Chef Table did not exist")

        try:
            array.remove('Deli')
        except:
            print("Deli did not exist")

        try:
            array.remove('Food Lab')
        except:
            print("Food Lab did not exist")

        try:
            array.remove('Pizza')
        except:
            print("Pizza did not exist")

        try:
            array.remove('Simple Servings')
        except:
            print("Simple Servings did not exist")

        try:
            array.remove('Soups')
        except:
            print("Soups did not exist")
    elif dh == 1:
        try:
            array.remove('LUNCH')
        except:
            print("LUNCH did not exist")

        try:
            array.remove('Deli')
        except:
            print("Deli did not exist")

        try:
            array.remove('Entrées')
        except:
            print("Entrées did not exist")

        try:
            array.remove('Grill')
        except:
            print("Grill did not exist")

        try:
            array.remove('International')
        except:
            print("International did not exist")

        try:
            array.remove('Pizza')
        except:
            print("Pizza did not exist")

        try:
            array.remove('Simple Servings')
        except:
            print("Simple Servings did not exist")

        try:
            array.remove('Soups')
        except:
            print("Soups did not exist")

        try:
            array.remove('Vegan')
        except:
            print("Vegan did not exist")

        try:
            array.remove('Vegan/ Vegetarian')
        except:
            print("Vegan/ Vegetarian did not exist")
    elif dh == 2:
        try:
            array.remove('LUNCH')
        except:
            print("LUNCH did not exist")

        try:
            array.remove('Basil')
        except:
            print("Basil did not exist")

        try:
            array.remove('Chef\'s Table')
        except:
            print("Chef\'s Table did not exist")

        try:
            array.remove('Daily Dish')
        except:
            print("Daily Dish did not exist")

        try:
            array.remove('Ignite')
        except:
            print("Ignite did not exist")
    else:
        print("Format unrecognized. Try again.")

    for i in range(0, len(array), 2):
        array[i+1] = array[i+1][:len(array[i+1])-3]

    return array;


def scrape_soup(dh, url):
    html = urlopen(url).read().decode('UTF-8')
    soup = BeautifulSoup(html, 'html.parser')
    day = datetime.datetime.today().day
    menu = soup.find_all('div', id="menuid-"+str(day)+"-day")[-1].get_text("|", strip=True)
    spliced = menu.split("|")

    lunch_start = spliced.index('LUNCH')
    try:
        lunch_end = spliced.index('DINNER')
    except:
        lunch_end = len(spliced)
    scraped = format_array(dh, spliced[lunch_start:lunch_end])
    display(scraped)
    return scraped


def display(scraped):
    for x in range(0, len(scraped), 2):
        print(str(scraped[x])+'\t'+str(scraped[x+1]))


def main():
    terraces = []
    campus_center = []
    towers = []
    # web scraping part
    print("----------terraces----------")
    try:
        terraces = scrape_soup(0, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
    except:
        print("Terraces did not respond")
    print("\n----------campus center----------")
    try:
        campus_center = scrape_soup(1, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
    except:
        print("Campus Center did not respond")
    print("\n----------towers----------")
    try:
        towers = scrape_soup(2, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")
    except:
        print("Towers did not respond")

    if len(terraces) != 0 or len(campus_center) != 0 or len(towers) != 0:
        # initialize database
        print("\n\n Opening database...")
        db = pymysql.connect(host="localhost", port=3306, user="tmarotta", passwd="nalgene21", db="LunchDate")

        # create cursor to call things
        cursor = db.cursor()

        # fill in data
        # dining hall string, food_item, calories as integer, date object?
        print("Entering Food Items...")
        hall_names = ["Towers", "Terraces", "Campus Center"]
        hall_menu = [towers, terraces, campus_center]
        day = datetime.datetime.now()
        for i in range(len(hall_names)):
            for j in range(0, len(hall_menu[i]), 2):
                sql ="""INSERT INTO meal_option (dining_hall, food_item, calories, date_available) VALUES (%s, %s, %s, %s)"""
                cursor.execute(sql, (hall_names[i], hall_menu[i][j], int(hall_menu[i][j+1]), day.date().isoformat()))
        print("Closing...")
        db.commit()
        db.close()
        print("Done.")
    else:
        print("No dining halls were available")


main()
