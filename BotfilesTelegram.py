import requests

# Set the API token and chat ID of your Telegram bot
api_token = 'your_api_token_here'
chat_id = 'your_chat_id_here'

# Define a list of URLs of the files you want to download
file_urls = ['http://example.com/file1.txt', 'http://example.com/file2.txt', 'http://example.com/file3.txt']

# Iterate over the list and download each file
for url in file_urls:
    # Send a GET request to download the file
    response = requests.get(url)

    # Extract the filename from the URL
    file_name = url.split('/')[-1]

    # Send the file to the Telegram bot using the sendDocument API endpoint
    api_url = f'https://api.telegram.org/bot{api_token}/sendDocument'
    params = {
        'chat_id': chat_id,
    }
    files = {
        'document': (file_name, response.content),
    }
    response = requests.post(api_url, params=params, files=files)

    # Check the status code of the response to make sure the file was sent successfully
    if response.status_code == 200:
        print(f'File "{file_name}" sent successfully.')
    else:
        print(f'Error sending file "{file_name}":', response.content)