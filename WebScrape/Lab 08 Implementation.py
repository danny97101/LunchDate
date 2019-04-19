'''
Name: Timothy Marotta
Date: November 28, 2017
Purpose: Lab 08 Implementation
'''
import urllib.request

def scrape(url,names,netpass):
    '''
    This function identifies names and corresponding netpass IDs and adds them to
    lists
    Args: a url,an empty list to add names to, and empty list to add netpassIDs to
    Returns: none
    '''
    data=urllib.request.urlopen(url)
    lines=data.readlines()
    for x in range(len(lines)):
        lines[x]=lines[x].decode("utf-8")
        if 'eportfolios' in lines[x]:
            loc=lines[x].find(".edu/")
            loc2=lines[x].find('/">')
            line=lines[x][loc+5:loc2]
            netpass.append(line)

            loc3=lines[x].find('/">')
            loc4=lines[x].find('</a>')
            line2=lines[x][loc3+3:loc4]
            names.append(line2)

def printLogins(names,net):
    '''
    Print all of the name and netpass information
    Args: a list of names, a list of netpass IDs
    Return: none
    '''
    for x in range(len(names)):
        print("Name: ", names[x])
        print("Netpass ID: ", net[x])
        print()

def main():
    '''
    Run the webscraping function and print results
    Args: none
    Return: none
    '''
    net = []
    names = []
    scrape("http://www.ithaca.edu/directories/eportfolios.php", names, net)
    printLogins(names, net)

main()
