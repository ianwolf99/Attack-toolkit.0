#!/bin/bash

# Prompt for input
read -p "Enter domain to scan: " domain

# Create output file
output="$domain.html"
echo "<html><head><title>Scan Results for $domain</title></head><body>" > $output

# Perform nmap scan to get open ports and service versions
echo "Scanning open ports and service versions for $domain..."
nmap -sV -T4 $domain | grep -E "^(Host|PORT|SERVICE|VERSION)" >> $output

# Perform whois lookup on domain
echo "Performing whois lookup on $domain..."
echo "<br><br><b>WHOIS Lookup Results:</b><br>" >> $output
whois $domain >> $output

# Identify OS using nmap
echo "Identifying OS for $domain..."
echo "<br><br><b>OS Identification Results:</b><br>" >> $output
nmap -O $domain | grep "Running:" >> $output

# Retrieve web technology information using Wappalyzer
echo "Retrieving web technology information for $domain..."
echo "<br><br><b>Web Technology Information:</b><br>" >> $output
wappalyzer $domain >> $output

# Identify databases using nmap-vulners
echo "Identifying databases for $domain..."
echo "<br><br><b>Database Identification Results:</b><br>" >> $output
nmap -sV --script=vulners,vulscan --script-args vulscan.systemauth --script-args vulscan.nmapdat=/usr/share/nmap/nmap.xsd $domain | grep -E "^(Host|PORT|SERVICE|VERSION|VULNERABILITY)" >> $output

# Close output file
echo "</body></html>" >> $output

echo "Scan results saved in $output"
