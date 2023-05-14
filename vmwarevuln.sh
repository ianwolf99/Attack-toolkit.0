#!/bin/bash

# Define target IP or hostname
target="example.com"

# Create output directory
mkdir -p vmware_scan

# Perform nmap port scan
echo "[*] Performing nmap port scan on ${target}..."
nmap -sS -p- -oN vmware_scan/nmap.txt ${target}

# Identify VMware services and versions
echo "[*] Identifying VMware services and versions..."
grep -E '^(Vmware|vmware|vSphere|vcenter|vsphere|vc)[^[:alpha:]]' vmware_scan/nmap.txt | sed 's/.*service/version: /g' | sort -u > vmware_scan/vmware_services.txt

# Perform OS detection with nmap
echo "[*] Performing OS detection on ${target}..."
nmap -O -oN vmware_scan/os_detection.txt ${target}

# Identify VMware vulnerabilities with Nessus
echo "[*] Identifying VMware vulnerabilities with Nessus..."
nessuscli --quiet --nogui --host ${target} --port 8834 --user <username> --password <password> --file vmware_scan/nessus_scan.nessus --plugin-set "VMware vSphere"

# Generate HTML report
echo "[*] Generating HTML report..."
nessuscli_report -i vmware_scan/nessus_scan.nessus -o vmware_scan/nessus_report.html -f HTML

# Print summary
echo "[+] Scan complete. Results saved in vmware_scan directory."
