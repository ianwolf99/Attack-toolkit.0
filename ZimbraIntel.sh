#!/bin/bash

# Input validation
if [ -z "$1" ]; then
    echo "Usage: ./zimbra_scan.sh <target_ip>"
    exit 1
fi

# Set target IP and output file
TARGET="$1"
OUTPUT="zimbra_scan_$(date +%Y%m%d_%H%M%S).html"

# Run nmap scan to identify open ports and services
nmap -Pn -sS -sV -p- -T4 -oX nmap.xml "$TARGET"

# Run zmap to check for zimbra-specific ports
zmap -p 7071 -o zimbra_ports.txt "$TARGET"
zmap -p 8443 -o zimbra_ports.txt "$TARGET"
zmap -p 7073 -o zimbra_ports.txt "$TARGET"
zmap -p 9071 -o zimbra_ports.txt "$TARGET"
zmap -p 7072 -o zimbra_ports.txt "$TARGET"

# Run nikto to scan for vulnerabilities in web applications
nikto -host "$TARGET" -p 7071 -output nikto_zimbra_7071.txt
nikto -host "$TARGET" -p 8443 -output nikto_zimbra_8443.txt
nikto -host "$TARGET" -p 7073 -output nikto_zimbra_7073.txt
nikto -host "$TARGET" -p 9071 -output nikto_zimbra_9071.txt
nikto -host "$TARGET" -p 7072 -output nikto_zimbra_7072.txt

# Run zimbra-autodiscover-scan to identify potential vulnerabilities in Zimbra's Autodiscover feature
zimbra-autodiscover-scan -t "$TARGET" -o zimbra_autodiscover_scan.txt

# Run whatweb to identify web technologies in use
whatweb -a 3 "$TARGET" > whatweb.txt

# Run wafw00f to detect web application firewalls
wafw00f "$TARGET" > wafw00f.txt

# Run theharvester to perform whois on the domain
theharvester -d "$(echo "$TARGET" | cut -d. -f2,3)" -b all -f "$OUTPUT"

# Run nmap OS detection
nmap -sS -O -T4 -oN "$OUTPUT" "$TARGET"

# Run nmap NSE scripts to check for potential vulnerabilities
nmap -sS -Pn -p 7071 --script zimbra-enum-users --script-args 'userdb=/path/to/userdb.txt' -oN "$OUTPUT" "$TARGET"
nmap -sS -Pn -p 7071 --script zimbra-bruteforce -oN "$OUTPUT" "$TARGET"

# Output summary to console and file
echo "Scan complete. Results saved to $OUTPUT"
cat "$OUTPUT"
