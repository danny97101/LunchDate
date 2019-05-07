from urllib.request import urlopen
from bs4 import BeautifulSoup
import re
import datetime


def find_2nd(string, substring):
    return string.find(substring, string.find(substring) + 1)


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
        # removes 'cal' from calorie information indexes
        array[i+1] = array[i+1][:len(array[i+1])-3]

    return array


def allergy_soup(url):
    html = urlopen(url).read().decode('UTF-8')
    soup = BeautifulSoup(html, 'html.parser')
    day = datetime.datetime.today().day
    text = soup.find_all('div', id="menuid-" + str(day) + "-day")[-1].contents
    test = str(text)
    iso = test[7:len(test)-7]
    to_array = iso.split("\n")
    lunch_start = to_array.index('<span class="accordion-copy">LUNCH</span>')
    try:
        lunch_end = to_array.index('<div class="accordion-block dinner">')
    except:
        lunch_end = len(to_array)
    smaller = to_array[lunch_start:lunch_end]
    ret = []
    for x in range(0, len(smaller)):
        if "fooditemname" in smaller[x]:
            hold = smaller[x][smaller[x].find('>')+1:len(smaller[x])-4]
            if "&amp;" in hold:
                hold2 = hold.replace("amp;", '')
                smaller[x] = hold2
                # print(hold2)
                ret.append(hold2.strip())
            else:
                smaller[x] = hold
                # print(hold)
                ret.append(hold.strip())
        elif "alt=" in smaller[x]:
            check = smaller[x][smaller[x].find('"')+1:find_2nd(smaller[x], '"')]
            if "contains" in check:
                smaller[x] = check[9:]
            else:
                smaller[x] = smaller[x][smaller[x].find('"')+1:find_2nd(smaller[x], '"')]
            # print(smaller[x])
            ret.append(smaller[x].strip())
    return ret


def scrape_soup(dh, url):
    html = urlopen(url).read().decode('UTF-8')
    soup = BeautifulSoup(html, 'html.parser')
    day = datetime.datetime.today().day
    menu = soup.find_all('div', id="menuid-" + str(day) + "-day")[-1].get_text("|", strip=True)
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


def two_dimension(to_change, compare):
    to_return = []
    for i in range(0, len(to_change)):
        if to_change[i] in compare:
            to_return.append([])
        else:
            to_return[-1].append(to_change[i])
    return to_return


def print_ready(to_print):
    print("\n\n")
    for i in range(0, len(to_print)):
        test = ""
        for j in range(0, len(to_print[i])):
            test += to_print[i][j] + "\t"
        print(test)


def main():
    terraces = []
    campus_center = []
    towers = []
    terr_allergen = []
    cc_allergen = []
    towers_allergen = []
    # web scraping part
    print("----------terraces----------")
    try:
        terraces = scrape_soup(0, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
        print("\n\n/////ALLERGENS FOR TERRACES/////")
        try:
            terr_allergen = allergy_soup("https://menus.sodexomyway.com/BiteMenu/Menu?menuId=364&locationId=10001002&whereami=https://ithaca.sodexomyway.com/dining-near-me/terrace-dining-hall")
        except Exception as err:
            print(err)
            pass
        terr_ready = two_dimension(terr_allergen, terraces)
        print_ready(terr_ready)
    except Exception as err:
        print(err)
        print("Terraces did not respond")
    # ------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------
    print("\n----------campus center----------")
    try:
        campus_center = scrape_soup(1, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
        print("\n\n/////ALLERGENS FOR CAMPUS CENTER/////")
        try:
            cc_allergen = allergy_soup("https://menus.sodexomyway.com/BiteMenu/Menu?menuId=362&locationId=10001001&whereami=https://ithaca.sodexomyway.com/dining-near-me/campus-center-dining-hall")
        except Exception as err:
            print(err)
            pass
        cc_ready = two_dimension(cc_allergen, campus_center)
        print_ready(cc_ready)
    except Exception as err:
        print(err)
        print("Campus Center did not respond")
    # ------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------
    print("\n----------towers----------")
    try:
        towers = scrape_soup(2, "https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")
        print("\n\n/////ALLERGENS FOR TOWERS/////")
        try:
            towers_allergen = allergy_soup("https://menus.sodexomyway.com/BiteMenu/Menu?menuId=1356&locationId=10001003&whereami=http://ithaca.sodexomyway.com/dining-near-me/towers-dining-hall")
        except Exception as err:
            print(err)
            pass
        towers_ready = two_dimension(towers_allergen, towers)
        print_ready(towers_ready)
    except Exception as err:
        print(err)
        print("Towers did not respond")


main()
