#!/bin/bash

# Bug Bounty Hunting Script

# Usage: ./bug_bounty.sh <target_url> <output_directory> <wordlist_file>

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <target_url> <output_directory> <wordlist_file>"
    exit 1
fi

target_url=$1
output_directory=$2
wordlist_file=$3

# Create the output directory if it doesn't exist
if [ ! -d "$output_directory" ]; then
    mkdir -p "$output_directory"
fi

# Start by performing an Nmap scan on the target URL
echo "Performing Nmap scan..."
nmap_scan=$(nmap -sS -p- "$target_url" -oN "$output_directory/nmap_scan.txt")

# Check if any open ports were found
if grep -q "open" "$output_directory/nmap_scan.txt"; then
    # Perform directory and file enumeration using Dirb and Gobuster
    echo "Performing Dirb and Gobuster scans..."
    dirb_scan=$(dirb "$target_url" "$wordlist_file" -o "$output_directory/dirb_scan.txt")
    gobuster_scan=$(gobuster dir -u "$target_url" -w "$wordlist_file" -e -o "$output_directory/gobuster_scan.txt")

    # Check if any interesting files were found using Dirb or Gobuster
    if grep -q -E "(php|html|jsp|asp|aspx)" "$output_directory/dirb_scan.txt" || grep -q -E "(php|html|jsp|asp|aspx)" "$output_directory/gobuster_scan.txt"; then
        # Perform LFI (Local File Inclusion) testing
        echo "Performing LFI testing..."
        lfi_tester=$(lfi_tester -u "$target_url" -p "/etc/passwd" -o "$output_directory/lfi_tester.txt")

        # Check if LFI vulnerabilities were found
        if grep -q "VULNERABLE" "$output_directory/lfi_tester.txt"; then
            echo "LFI vulnerability found"
        fi
    fi

    # Check for potential path traversal vulnerabilities using DotDotPwn
    echo "Checking for potential path traversal vulnerabilities..."
    dotdotpwn_scan=$(dotdotpwn.pl -m http -h "$target_url" -o "$output_directory/dotdotpwn_scan.txt")

    # Check if potential path traversal vulnerabilities were found
    if grep -q "Potential Vulnerability Found!" "$output_directory/dotdotpwn_scan.txt"; then
        echo "Potential path traversal vulnerability found"
    fi

    # Use wfuzz to identify parameters and test for injection vulnerabilities
    echo "Identifying parameters using wfuzz..."
    wfuzz_scan=$(wfuzz -c -w "$wordlist_file" "$target_url?FUZZ=test" 2> /dev/null)

    # Save the identified parameters to a file
    echo "$wfuzz_scan" | grep -oE "^\[INFO\] ([0-9]+) requests" | awk '{print $3}' | sort -u > "$output_directory/parameters.txt"

    # Check if any parameters were identified
    if [-s "$output_directory/parameters.txt" ];then
# Perform SQL injection testing using SQLMap
echo "Performing SQL injection testing using SQLMap..."
sqlmap_scan=$(sqlmap -m "$output_directory/parameters.txt" --batch --output-dir="$output_directory/sqlmap_scan")
    # Check if SQL injection vulnerabilities were found
    if grep -q "available databases" "$output_directory/sqlmap_scan/*"; then
        echo "SQL injection vulnerability found"
    fi

    # Perform command injection testing using Commix
    echo "Performing command injection testing using Commix..."
    commix_scan=$(commix -u "$target_url" --output "$output_directory/commix_scan.txt")

    # Check if command injection vulnerabilities were found
    if grep -q "COMMAND_INJECTION" "$output_directory/commix_scan.txt"; then
        echo "Command injection vulnerability found"
    fi
fi

echo "Crawling the target URL using ParamSpider..."
paramspider_scan=$(paramspider.py --domain "$target_url" --output "$output_directory/paramspider_scan.txt")

echo "Generating the HTML report..."
cat <<EOF > "$output_directory/report.html"

<html>
<head>
    <title>Bug Bounty Scan Report</title>
</head>
<body>
    <h1>Bug Bounty Scan Report</h1>
    <h2>Nmap Scan Results</h2>
<pre>$(cat "$output_directory/nmap_scan.txt")</pre>

<h2>Dirb Scan Results</h2>
<pre>$(cat "$output_directory/dirb_scan.txt")</pre>

<h2>Gobuster Scan Results</h2>
<pre>$(cat "$output_directory/gobuster_scan.txt")</pre>

<h2>LFI Tester Results</h2>
<pre>$(cat "$output_directory/lfi_tester.txt")</pre>

<h2>DotDotPwn Scan Results</h2>
<pre>$(cat "$output_directory/dotdotpwn_scan.txt")</pre>

<h2>Wfuzz Scan Results</h2>
<pre>$(cat "$output_directory/parameters.txt")</pre>

<h2>SQLMap Scan Results</h2>
<pre>$(cat "$output_directory/sqlmap_scan/*")</pre>

<h2>Commix Scan Results</h2>
<pre>$(cat "$output_directory/commix_scan.txt")</pre>

<h2>ParamSpider Scan Results</h2>
<pre>$(cat "$output_directory/paramspider_scan.txt")</pre>
</body>
</html>
EOF
echo "Report generated at: $output_directory/report.html"



