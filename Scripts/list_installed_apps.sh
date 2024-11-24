#!/bin/bash

## This script will list out all the apps installed sorted by name. This output will be used in the JXA script for delayed start of applications in Keyboard Maestro


# Function to recursively find .app files
find_apps() {
  find "$1" -maxdepth 2 -type d -name "*.app" -exec basename {} .app \;
}

# Find apps in /Applications
apps_in_system=$(find_apps "/Applications")

# Find apps in ~/Applications and its subfolders (one level deep)
apps_in_home=$(find_apps "~/Applications")

# Combine the results, sort them case-insensitively, and remove duplicates
all_apps=$(echo -e "$apps_in_system\n$apps_in_home" | sort -fu)

# Print the list of applications
echo "var apps = ["
while IFS= read -r app; do
  echo "  { name: '$app', delay: 5 },"
  #echo "$app"
done <<< "$all_apps"
echo "];"

