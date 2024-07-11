#!/bin/bash

# install_packages.sh

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if a folder path is provided as an argument, otherwise use the current directory
folder_path=${1:-$(pwd)}

# Change to the specified folder
cd "$folder_path" || { echo -e "${RED}Folder not found${NC}"; exit 1; }

# Get the list of zip files in the folder
packages=( ./*.zip )

# Get the total number of packages
total_packages=${#packages[@]}

# Initialize the counter
counter=0

# Loop through each zip file in the folder and run the curl command
for package in "${packages[@]}"; do
  ((counter++))
  echo -e "\nInstalling package $counter of $total_packages: $package"
  
  # Send the package and capture the HTTP response code
  response=$(curl -s -o /dev/null -w "%{http_code}" -u admin:admin -F file=@"$package" -F name="content-dam" -F force=true -F install=true http://localhost:4502/crx/packmgr/service.jsp)
  
  # Check if the installation was successful (HTTP response code 200)
  if [ "$response" -eq 200 ]; then
    echo -e "${GREEN}Installation successful for package: $package${NC}\n"
  else
    echo -e "${RED}Installation failed for package: $package (HTTP response code: $response)${NC}\n"
  fi
  
  # Calculate and display the percentage of packages installed
  percentage=$(awk "BEGIN { pc=($counter/$total_packages)*100; printf \"%.2f\", pc }")
  echo -e "Progress: $percentage% ($counter of $total_packages packages installed)\n"
done
