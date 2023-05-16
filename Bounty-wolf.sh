#!/bin/bash

# Define variables for the script
target="example.com"
output_directory="output"
nmap_options="-sS -T4"
nikto_options="-h $target -port 80,443 -Format htm"
gobuster_options="-w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -k -o $output_directory/gobuster_scan.txt -u https://$target/"
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

  # Example using s3scanner
  echo "Running s3scanner on $target..."
  s3scanner --url "$target" --output "$output_directory/s3scanner_scan.txt"

  # Example using wfuzz
  echo "Running wfuzz scan on $target..."
  wfuzz -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hc 404 "$target/FUZZ" > "$output_directory/wfuzz_scan.txt"

  # Example using dotdotpwn
  echo "Running dotdotpwn scan on $target..."
  dotdotpwn.pl -m http -h "$target" -o "$output_directory/dotdotpwn_scan.txt"

  # Example using Lfi tester
  echo "Running Lfi tester scan on $target..."
  python /usr/share/wfuzz/tools/lfi/LFI.py -u "$target/index.php?page=FUZZ" -t ../../../../../../../../../../etc/passwd -o "$output_directory/lfi_tester_scan.txt"

  # Example using commix
  echo "Running commix scan on $target..."
  commix --url "$target" --batch --output-dir "$output_directory/commix_scan"

  # Example using sqlmap
  echo "Running sqlmap scan on $target..."
  sqlmap -u "$target" --batch --output-dir "$output_directory/sqlmap_scan"

  # Example using paramspider
  echo "Running paramspider on $target..."
  paramspider --domain "$target" --output "$output_directory/paramspider_scan.txt"
else
  echo "No open ports found. Skipping vulnerability scan."
fi

# Consolidate all scan results into an HTML report
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
<h2>Dirb Scan Results</h2>
<pre>$(cat "$output_directory/dirb_scan.txt")</pre>
<h2>Gobuster Scan Results</h2>
<pre>$(cat "$output_directory/gobuster_scan.txt")</pre>
<h2>s3scanner Scan Results</h2>
<pre>$(cat "$output_directory/s3scanner_scan.txt")</pre>
<h2>wfuzz Scan Results</h2>
<pre>$(cat "$output_directory/wfuzz_scan.txt")</pre>
<h2>dotdotpwn Scan Results</h2>
<pre>$(cat "$output_directory/dotdotpwn_scan.txt")</pre>
<h2>Lfi tester Scan Results</h2>
<pre>$(cat "$output_directory/lfi_tester_scan.txt")</pre>
<h2>Commix Scan Results</h2>
<pre>$(cat "$output_directory/commix_scan/commix_report.txt")</pre>
<h2>Sqlmap Scan Results</h2>
<pre>$(cat "$output_directory/sqlmap_scan/output.txt")</pre>
<h2>Paramspider Scan Results</h2>
<pre>$(cat "$output_directory/paramspider_scan.txt")</pre>
<!-- Include other scan results here -->
</body>
</html>
EOF
echo "Report generated at: $output_html"