import urllib.request

def scrape(url,names,netpass):
    '''
    This function identifies names and corresponding netpass IDs and adds them to
    lists
    Args: a url,an empty list to add names to, and empty list to add netpassIDs to
    Returns: none
    '''
    data=urllib.request.urlopen(url)

    #for all of the data read from the webpage
    #  identify where the names and netpass IDs appear
    #  identify the beginning and end points of where the data is contained
    #  slice out the appropriate parts and add to the lists

def printLogins(name,net):
    '''
    Print all of the name and netpass information
    Args: a list of names, a list of netpass IDs
    Return: none
    '''
    #Print each name followed by it's netpass

def main():
    '''
    Run the webscraping function and print results
    Args: none
    Return: none
    '''
    net=[]
    names=[]
    scrape("http://www.ithaca.edu/directories/eportfolios.php",names,net)
    printLogins(names,net)

main()
