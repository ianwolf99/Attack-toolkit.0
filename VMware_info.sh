#!/bin/bash

# Script to gather information about a VMware server

# Usage: ./vmware-info.sh <ip-address>

# Check if IP address is provided
if [ -z "$1" ]
then
  echo "Usage: ./vmware-info.sh <ip-address>"
  exit 1
fi

# Variables
IP=$1
OUTPUT_FILE="vmware-info.html"

# Check if output file exists, if not, create it
if [ ! -f "$OUTPUT_FILE" ]
then
  touch "$OUTPUT_FILE"
fi

# Banner
echo "-------------------------"
echo "VMware Server Information"
echo "-------------------------"

# Port scanning with Nmap
echo "[*] Scanning for open ports..."
nmap -sS -T4 -p- "$IP" -oN "$OUTPUT_FILE"

# Service version detection with Nmap
echo "[*] Detecting services and their versions..."
nmap -sS -sV -p $(cat "$OUTPUT_FILE" | grep -E '^[0-9]+/' | cut -d'/' -f1 | tr '\n' ',') "$IP" -oN "$OUTPUT_FILE"

# OS detection with Nmap
echo "[*] Detecting the operating system..."
nmap -sS -O "$IP" -oN "$OUTPUT_FILE"

# VMware vulnerability scanning with OpenVAS
echo "[*] Scanning for vulnerabilities using OpenVAS..."
openvasmd --create-target="$IP" --name="$IP"
target_id=$(openvasmd --get-targets | grep "$IP" | cut -d' ' -f1)
openvasmd --create-task="$target_id" --name="VMware Vulnerability Scan" --scanner="openvas" --description="A vulnerability scan of a VMware server"
task_id=$(openvasmd --get-tasks | grep "$IP" | cut -d' ' -f1)
openvasmd --start-task="$task_id"
sleep 10
openvasmd --get-results="$task_id" -f "$OUTPUT_FILE"
openvasmd --delete-task="$task_id"
openvasmd --delete-target="$target_id"

# VMware product information gathering with vCenter
echo "[*] Gathering VMware product information..."
echo "" >> "$OUTPUT_FILE"
echo "<h2>VMware Product Information</h2>" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
curl -s -k -u 'root:vmware' https://"$IP"/sdk/vimServiceVersions.xml | grep -o '<version>.*</version>' | cut -d'>' -f2 | cut -d'<' -f1 >> "$OUTPUT_FILE"
curl -s -k -u 'root:vmware' https://"$IP"/sdk/vimServiceVersions.xml | grep -o '<version>.*</version>' | cut -d'>' -f2 | cut -d'<' -f1 | while read line ; do
  echo "" >> "$OUTPUT_FILE"
  curl -s -k -u 'root:vmware' https://"$IP"/sdk/vimService.wsdl\?version="$line" | grep -o '<wsdl:service>.*</wsdl:service>' | cut -d'>' -f2 | cut -d'<' -f1 >> "$OUTPUT_FILE"
done

# Print summary
echo "[*] Summary saved to $OUTPUT_FILE"
