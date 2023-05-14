#!/bin/bash

# Usage: ./vmware-info-gather.sh <IP_Address>

# Check if IP address is provided
if [ -z "$1" ]; then
  echo "Usage: ./vmware-info-gather.sh <IP_Address>"
  exit 1
fi

# Set variables
ip_address=$1
output_file="vmware-info.html"

# Create HTML file
echo "<html><head><title>VMware Info Gather Report</title></head><body>" > $output_file

# Perform nmap scan to identify open ports and services
echo "[*] Scanning open ports and services..."
nmap -sV -oX nmap-output.xml $ip_address > /dev/null 2>&1
xsltproc nmap-output.xml -o $output_file >> $output_file

# Perform OS detection with nmap
echo "[*] Performing OS detection..."
os=`nmap -O $ip_address | grep "Running:" | awk '{print $2" "$3" "$4}'`
echo "<p>Operating System: $os</p>" >> $output_file

# Perform vulnerability scanning with OpenVAS
echo "[*] Scanning for vulnerabilities with OpenVAS..."
docker run -d -p 443:443 -p 9390:9390 mikesplain/openvas > /dev/null 2>&1
sleep 60
openvas-cli --user=admin --password=admin --create-target=$ip_address --name="VMware Server" > /dev/null 2>&1
task_id=$(openvas-cli --user=admin --password=admin --create-task="VMware Server Vulnerability Scan" --target=$ip_address --scanner="OpenVAS Default" --status=New | awk '{print $2}')
openvas-cli --user=admin --password=admin --start-task=$task_id > /dev/null 2>&1
sleep 180
report_id=$(openvas-cli --user=admin --password=admin --get-report-id=$task_id)
report=$(openvas-cli --user=admin --password=admin --get-report=$report_id)
echo "<h3>Vulnerability Scan Report</h3><pre>$report</pre>" >> $output_file
docker stop $(docker ps -q)

# Perform web technology identification with Wappalyzer
echo "[*] Identifying web technologies..."
wappalyzer -u https://$ip_address -xml | xsltproc -o $output_file - >> $output_file

# Perform SSL/TLS scanning with testssl.sh
echo "[*] Performing SSL/TLS scanning..."
testssl.sh $ip_address > testssl-output.txt
echo "<h3>SSL/TLS Scan Report</h3><pre>" >> $output_file
cat testssl-output.txt >> $output_file
echo "</pre>" >> $output_file

# Perform SMTP enumeration with smtp-user-enum
echo "[*] Performing SMTP enumeration..."
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t $ip_address >> smtp-enum-output.txt
echo "<h3>SMTP Enumeration Report</h3><pre>" >> $output_file
cat smtp-enum-output.txt >> $output_file
echo "</pre>" >> $output_file

# Perform DNS enumeration with dnsrecon
echo "[*] Performing DNS enumeration..."
dnsrecon -d $ip_address >> dns-enum-output.txt
echo "<h3>DNS Enumeration Report</h3><pre>" >> $output_file
cat dns-enum
