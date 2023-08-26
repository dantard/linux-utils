#!/bin/bash

# Function to find the newest file in a directory
find_newest_file() {
    local dir="$1"
    local newest_file=$(ls -t "$dir" | head -1)
    local modification_date=$(stat -c %Y "$dir/$newest_file")
    echo "$modification_date:$dir:$newest_file"
}

# Check if the script should run recursively
recursive_search=false
if [ "$1" = "-r" ]; then
    recursive_search=true
    shift
fi

# Get the search directory from the command line argument
search_dir="$1"

# Perform the search and sort results by modification date
if [ "$recursive_search" = true ]; then
    # Recursive search
    while IFS= read -r dir; do
        find_newest_file "$dir"
    done < <(find "$search_dir" -type d)
else
    # Non-recursive search
    for dir in "$search_dir"/*; do
        if [ -d "$dir" ]; then
            find_newest_file "$dir"
        fi
    done
fi | sort -t ':' -k 1,1nr | while IFS=':' read -r date dir file; do
    formatted_date=$(date -d "@$date" +"%Y-%m-%d %H:%M:%S")
    printf "%-20s %-50s %s\n" "$formatted_date" "Newest file in $dir:" "$file"
done

