#!/bin/bash

# Define variables for the script
target="example.com"
output_directory="output"
nmap_options="-sS -T4"
nikto_options="-h $target -port 80,443 -Format htm"
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

  # Example using Gobuster
  echo "Running Gobuster scan on $target..."
  gobuster dir -u "https://$target/" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o "$output_directory/gobuster_scan.txt" -t 50

  # Example using wfuzz
  echo "Running wfuzz scan on $target..."
  wfuzz -c -z file,/usr/share/wfuzz/wordlist/general/common.txt --hc 404 "https://$target/FUZZ" > "$output_directory/wfuzz_scan.txt"

  # Example using paramspider
  echo "Running paramspider scan on $target..."
  python3 /usr/share/paramspider/paramspider.py --domain "$target" --output "$output_directory/paramspider_scan.txt"

  # Example using s3scanner
  echo "Running s3scanner scan on $target..."
  s3scanner scan --url "$target" --output "$output_directory/s3scanner_scan.txt"

  # Example using sqlmap
  echo "Running sqlmap scan on $target..."
  sqlmap -u "https://$target/" --batch --output-dir="$output_directory/sqlmap_scan"

  # Example using dotdotpwn
  echo "Running dotdotpwn scan on $target..."
  dotdotpwn.pl -m http -h "$target" -M GET -o "$output_directory/dotdotpwn_scan.txt"

  # Example using Lfi tester
  echo "Running Lfi tester scan on $target..."
  lfi_tester -u "https://$target/" -s -p /etc/passwd -o "$output_directory/lfi_tester_scan.txt"

  # Example using commix
  echo "Running commix scan on $target..."
  commix --url "https://$target/" --output-dir "$output_directory/commix_scan"

  # Perform additional scans with other tools

else
  echo "No open ports found. Skipping vulnerability scan."
fi

# Check if the target has any APIs exposed
echo "Checking for exposed APIs on $target..."
if curl -s "$target/api" | grep -q "API documentation"; then
  echo "API found!"
else
  echo "No APIs found."
fi

# Identify all parameters in the target
echo "Identifying parameters on $target..."
grep -oP "(?<=?|&)[^&=]+" "$output_directory/nikto_scan.htm" | sort -u > "$output_directory/parameters.txt"
echo "Parameters saved to $output_directory/parameters.txt"

echo "Consolidating scan results into HTML report..."
cat <<EOF > "$output_html"

<html>
<head>
<title>Bug Bounty Scan Report</title>
</head>
<body>
<h1>Bug Bounty Scan Report</h1>
<h2>Nmap Scan Results</h2>
<pre>$(cat "$output_directory/nmap_scan.txt")</pre>
<h2>Nikto Scan Results</h2>
<pre>$(cat "$output_directory/nikto_scan.htm")</pre>
<h2>Gobuster Scan Results</h2>
<pre>$(cat "$output_directory/gobuster_scan.txt")</pre>
<h2>Wfuzz Scan Results</h2>
<pre>$(cat "$output_directory/wfuzz_scan.txt")</pre>
<h2>Paramspider Scan Results</h2>
<pre>$(cat "$output_directory/paramspider_scan.txt")</pre>
<h2>S3Scanner Scan Results</h2>
<pre>$(cat "$output_directory/s3scanner_scan.txt")</pre>
<h2>SQLMap Scan Results</h2>
<pre>$(cat "$output_directory/sqlmap_scan/output")</pre>
<h2>DotDotPwn Scan Results</h2>
<pre>$(cat "$output_directory/dotdotpwn_scan.txt")</pre>
<h2>LFI Tester Scan Results</h2>
<pre>$(cat "$output_directory/lfi_tester_scan.txt")</pre>
<h2>Commix Scan Results</h2>
<pre>$(cat "$output_directory/commix_scan/output")</pre>
<!-- Include other scan results here -->
</body>
</html>
EOF
echo "Report generated at: $output_html"

