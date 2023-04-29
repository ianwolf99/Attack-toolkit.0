import requests
from bs4 import BeautifulSoup

# Set the Google search URL
url = 'https://www.google.com/search?q=intext%3A%22BulletProof+Security%22+intext%3A%22Version+4.%22+intext%3A%22WordPress%22'

# Set the user agent string to simulate a browser
user_agent = {'User-agent': 'Mozilla/5.0'}

# Send a request to Google and get the HTML response
response = requests.get(url, headers=user_agent)
html = response.text

# Parse the HTML response with BeautifulSoup
soup = BeautifulSoup(html, 'html.parser')

# Find all the search result links
links = soup.find_all('a')

# Loop through the links and print the URLs of WordPress sites with BulletProof Security less than 5.0
for link in links:
    url = link.get('href')
    if url.startswith('/url?q=') and 'wordpress' in url and 'bulletproof-security' in url and 'version 5' not in url:
        url = url.replace('/url?q=', '').split('&')[0]
        print(url)