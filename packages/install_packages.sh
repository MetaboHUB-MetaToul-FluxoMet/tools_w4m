#!/bin/bash

cd /home/llegregam/Documents/tools_w4m/packages

# List of GitHub repositories
repos=(
    "https://github.com/MetaSys-LISBP/PhysioFit.git"
    "https://github.com/MetaboHUB-MetaToul-FluxoMet/PhysioFit_Data_Manager.git"
    "https://github.com/MetaboHUB-MetaToul-FluxoMet/Isoplot.git"
    "https://github.com/llegregam/influx_data_manager.git"
    "https://github.com/MetaSys-LISBP/IsoCor.git"
)

# Directory to store the cloned repositories
clone_dir="cloned_repos"

# Create the clone directory if it doesn't exist
mkdir -p "$clone_dir"

# Loop over each repository
for repo in "${repos[@]}"; do
  # Extract the repository name from the URL
  repo_name=$(basename "$repo" .git)
  
  # Change to the clone directory
  cd "$clone_dir"
  
  # Check if the repository has already been cloned
  if [ -d "$repo_name" ]; then
    # Change to the repository directory
    cd "$repo_name"
    
    # Fetch the latest changes
    git fetch
    
    # Get the current branch name
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if there are any new changes
    if git diff --quiet origin/"$branch_name"; then
      echo "No changes in $repo_name"
    else
      echo "Changes detected in $repo_name, pulling latest changes"
      git pull
    fi
    
    # Change back to the clone directory
    cd ..
  else
    # Clone the repository
    echo "Cloning $repo_name"
    git clone "$repo"
  fi
  
  # Change back to the original directory
  cd - > /dev/null
done

# Activate the Galaxy virtual environment
source /home/llegregam/Documents/tools_w4m/galaxy/.venv/bin/activate

# Install each tool into the Galaxy environment
for repo in "${repos[@]}"; do
  repo_name=$(basename "$repo" .git)
  tool_dir="$clone_dir/$repo_name"
  
  if [ -d "$tool_dir" ]; then
    echo "Installing $repo_name into the Galaxy environment"
    cd "$tool_dir"
    
    # Install the tool using pip install .
    pip install .
    
    cd - > /dev/null
  else
    echo "Directory $tool_dir does not exist, skipping installation"
  fi
done
