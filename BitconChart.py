import requests
import matplotlib.pyplot as plt

# Define the API endpoint for Coinbase
url = 'https://api.coinbase.com/v2/prices/BTC-USD/historic'

# Define the query parameters
params = {'period': 'day'}

# Send a GET request to the API endpoint
response = requests.get(url, params=params)

# Extract the price data from the response
data = response.json()['data']

# Extract the timestamp and price values into separate lists
timestamps = [item['time'] for item in data]
prices = [float(item['price']) for item in data]

# Plot the price data as a chart
plt.plot(timestamps, prices)
plt.xlabel('Timestamp')
plt.ylabel('Price (USD)')
plt.title('Bitcoin Price Chart')
plt.show()