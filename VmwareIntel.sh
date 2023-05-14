#!/bin/bash

# Define variables
target_ip="10.0.0.1"
vmware_port="443"
report_file="vmware_info.html"
vulnerability_check=true

# Function to run nmap scan and detect open ports
nmap_scan() {
    echo "Running nmap scan on ${target_ip}..."
    nmap -p- -T4 -oN nmap_results.txt ${target_ip}
    echo "Nmap scan complete."
}

# Function to identify services and operating system using nmap
nmap_service_identification() {
    echo "Identifying services and operating system using nmap..."
    nmap -sV -O -oN nmap_results.txt ${target_ip}
    echo "Service and OS identification complete."
}

# Function to check for vulnerabilities affecting VMware
check_vulnerabilities() {
    echo "Checking for vulnerabilities affecting VMware..."
    if [[ "$(grep -i 'vmware' nmap_results.txt)" ]]; then
        echo "VMware found on target system."
        if [ "${vulnerability_check}" = true ]; then
            echo "Running vulnerability scan using Nessus..."
            # Replace <NESSUS_SCAN_ID> and <NESSUS_API_KEY> with actual values
            nessuscli scan launch <NESSUS_SCAN_ID> --host ${target_ip} --template "VMware vSphere" --target-by "name" --user "<NESSUS_API_KEY>"
            echo "Vulnerability scan complete."
        fi
    else
        echo "VMware not found on target system."
    fi
}

# Function to generate HTML report
generate_report() {
    echo "Generating HTML report..."
    echo "<h1>VMware Information Gathering Report</h1>" > ${report_file}
    echo "<h2>Target IP: ${target_ip}</h2>" >> ${report_file}
    echo "<h3>Nmap Results:</h3>" >> ${report_file}
    cat nmap_results.txt | sed 's/$/<br>/' >> ${report_file}
    if [ "${vulnerability_check}" = true ]; then
        echo "<h3>Vulnerability Scan Results:</h3>" >> ${report_file}
        cat /opt/nessus/var/nessus/logs/nessusd.messages | sed 's/$/<br>/' >> ${report_file}
    fi
    echo "HTML report generated."
}

# Main function
main() {
    nmap_scan
    nmap_service_identification
    check_vulnerabilities
    generate_report
}

# Execute main function
main
