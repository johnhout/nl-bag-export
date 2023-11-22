#!/bin/bash

# Set the base directory to the GitHub workspace
base_dir="$GITHUB_WORKSPACE/data/bag"
download_url="https://service.pdok.nl/kadaster/adressen/atom/v1_0/downloads/lvbag-extract-nl.zip"

# Create the base directory and change to it
mkdir -p "$base_dir"
cd "$base_dir" || exit

# Download and unzip the main file
curl -o lvbag-extract-nl.zip "$download_url"
unzip lvbag-extract-nl.zip
rm lvbag-extract-nl.zip

# Function to process each directory
process_directory() {
    local directory=$1
    cd "$directory" || return

    # Unzip all zip files in the current directory
    for zip in *.zip; do
        [ -e "$zip" ] || continue
        unzip "$zip"
        rm -f "$zip"
    done

    # Convert all xml files to json
    for xml in *.xml; do
        [ -e "$xml" ] || continue
        local json="${xml%.xml}.json"
        npx convert-xml-to-json "$xml" "$json"
        rm -f "$xml"
    done

    # Go back to the parent directory
    cd ..
}

# Export the function so it's available to subshells
export -f process_directory

# Find all directories in the base directory and process them
find "$base_dir" -type d -exec bash -c 'process_directory "$0"' {} \;

echo "Processing complete."
