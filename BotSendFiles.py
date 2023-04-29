import requests

# Set the API token and chat ID of your Telegram bot
api_token = 'your_api_token_here'
chat_id = 'your_chat_id_here'

# Set the path of the file you want to send
file_path = '/path/to/your/file.jpg'

# Construct the URL for the Telegram API endpoint
api_url = f'https://api.telegram.org/bot{api_token}/sendPhoto'

# Set the parameters of the POST request
params = {
    'chat_id': chat_id,
}

# Open the file in binary mode and attach it to the POST request
with open(file_path, 'rb') as file:
    response = requests.post(api_url, params=params, files={'photo': file})

# Check the status code of the response to make sure the file was sent successfully
if response.status_code == 200:
    print('File sent successfully.')
else:
    print('Error sending file:', response.content)