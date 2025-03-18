#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use fzf to select a .yaml or .yml file in the script's directory
file=$(find "$script_dir" -maxdepth 1 -name "*.yaml" -o -name "*.yml" | fzf --prompt="Select a file to upload: ")

if [ -n "$file" ]; then
    echo "You selected $(basename "$file")"
    cat $file
    # Use the selected file in the curl command and parse the returned JSON to extract the id
    id=$(curl -s -X POST --data-binary @"$file" https://factory.talos.dev/schematics | jq -r '.id')
    echo "ID: $id"
    # Copy the id to the clipboard
    echo "$id" | pbcopy
else
    echo "No file selected."
fi
