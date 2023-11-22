#!/bin/bash

# Set the base directory to the GitHub workspace
base_dir="$GITHUB_WORKSPACE/data/bag"

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
