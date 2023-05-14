#!/bin/bash

# Script to gather information about a Zimbra server

# Set variables
TARGET=$1
OUTPUT_FILE=output.html

# Run nmap scan to identify open ports and services
echo "Running nmap scan..."
nmap -sV -T4 -p- $TARGET -oN nmap_output.txt > /dev/null 2>&1

# Extract ports and services from nmap output
echo "Extracting ports and services from nmap output..."
PORTS_AND_SERVICES=$(cat nmap_output.txt | grep -E '^[0-9]+/tcp' | awk '{print $1"/"$3}' | tr '\n' ',' | sed 's/,$//')

# Run OS detection using nmap
echo "Running OS detection using nmap..."
OS=$(nmap -O $TARGET | grep "Running" | awk '{print $2}')

# Run Zimbra version detection using nmap
echo "Running Zimbra version detection using nmap..."
ZIMBRA_VERSION=$(nmap -sV -p- $TARGET | grep "zimbra" | awk '{print $5}' | sed 's/.$//')

# Run Zimbra vulnerability scan using Nmap NSE script
echo "Running Zimbra vulnerability scan using NSE script..."
nmap --script zimbra-vulns $TARGET -oN zimbra_vuln_output.txt > /dev/null 2>&1

# Extract Zimbra vulnerabilities from NSE script output
echo "Extracting Zimbra vulnerabilities from NSE script output..."
ZIMBRA_VULNS=$(cat zimbra_vuln_output.txt | grep "VULNERABLE:" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

# Use WhatWeb to identify web technologies used on the server
echo "Using WhatWeb to identify web technologies used on the server..."
whatweb --color=never -a 3 -v $TARGET > whatweb_output.txt

# Extract web technologies from WhatWeb output
echo "Extracting web technologies from WhatWeb output..."
WEB_TECHNOLOGIES=$(cat whatweb_output.txt | grep -E '^[^ ]' | tr '\n' ',' | sed 's/,$//')

# Use nmap to identify database services
echo "Using nmap to identify database services..."
DATABASE_SERVICES=$(cat nmap_output.txt | grep -E '^[0-9]+/tcp' | grep -E 'mysql|postgresql|mariadb|oracle' | awk '{print $3}' | tr '\n' ',' | sed 's/,$//')

# Use whois to gather domain registration information
echo "Using whois to gather domain registration information..."
whois $TARGET > whois_output.txt

# Create HTML report
echo "Creating HTML report..."
cat <<EOF > $OUTPUT_FILE
<html>
<head>
<title>Zimbra server scan results for $TARGET</title>
</head>
<body>
<h1>Zimbra server scan results for $TARGET</h1>
<p><b>Ports and services:</b> $PORTS_AND_SERVICES</p>
<p><b>Operating system:</b> $OS</p>
<p><b>Zimbra version:</b> $ZIMBRA_VERSION</p>
<p><b>Zimbra vulnerabilities:</b> $ZIMBRA_VULNS</p>
<p><b>Web technologies:</b> $WEB_TECHNOLOGIES</p>
<p><b>Database services:</b> $DATABASE_SER
