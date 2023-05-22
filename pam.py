import requests

class ShiftTechMpesaAPI:
    def __init__(self, api_key, api_secret, environment='sandbox'):
        self.api_key = api_key
        self.api_secret = api_secret
        self.environment = environment

        if self.environment == 'sandbox':
            self.base_url = 'https://sandbox.shifttech.co.ke/api/v2/mpesa'
        else:
            self.base_url = 'https://api.shifttech.co.ke/api/v2/mpesa'

    def _send_request(self, endpoint, payload):
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {self.api_key}:{self.api_secret}'
        }
        url = f'{self.base_url}/{endpoint}'

        response = requests.post(url, json=payload, headers=headers)
        response_data = response.json()
        return response_data

    def check_balance(self, account_number):
        endpoint = 'account/balance'
        payload = {
            'account_number': account_number
        }
        response_data = self._send_request(endpoint, payload)
        return response_data

    def deposit_funds(self, account_number, amount):
        endpoint = 'account/deposit'
        payload = {
            'account_number': account_number,
            'amount': amount
        }
        response_data = self._send_request(endpoint, payload)
        return response_data

    def withdraw_funds(self, account_number, amount):
        endpoint = 'account/withdraw'
        payload = {
            'account_number': account_number,
            'amount': amount
        }
        response_data = self._send_request(endpoint, payload)
        return response_data

    def transfer_funds(self, sender_account, recipient_account, amount):
