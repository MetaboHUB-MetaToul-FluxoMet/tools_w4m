# This script clones the repositories of the tools to be installed in the Galaxy environment, 
# updates them if they already exist, and installs them into the Galaxy environment.
# Launch the script from the root directory where the repositories should be cloned, or are already cloned.

#!/bin/bash

# Save initial directory
initial_dir=$(pwd)

# List of GitHub repositories
repos=(
    "https://github.com/MetaSys-LISBP/PhysioFit.git"
    "https://github.com/MetaboHUB-MetaToul-FluxoMet/PhysioFit_Data_Manager.git"
    "https://github.com/MetaboHUB-MetaToul-FluxoMet/Isoplot.git"
    "https://github.com/llegregam/influx_data_manager.git"
    "https://github.com/MetaSys-LISBP/IsoCor.git"
    "https://github.com/sgsokol/influx.git"
    "https://github.com/MetaboHUB-MetaToul-FluxoMet/Skyline2IsoCor.git"
)

# Directory to store the cloned repositories
clone_dir="$initial_dir/cloned_repos"

# Create the clone directory if it doesn't exist
mkdir -p "$clone_dir"

# Clone/update repositories
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    
    if [ -d "$clone_dir/$repo_name" ]; then
        pushd "$clone_dir/$repo_name" > /dev/null
        echo "Updating $repo_name..."
        git fetch
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        git pull origin "$branch_name"
        popd > /dev/null
    else
        pushd "$clone_dir" > /dev/null
        echo "Cloning $repo_name..."
        git clone "$repo"
        popd > /dev/null
    fi
done

# Activate the Galaxy virtual environment
source /home/llegregam/Documents/tools_w4m/galaxy/.venv/bin/activate

# Install each tool into the Galaxy environment
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    tool_dir="$clone_dir/$repo_name"
    
    if [ -d "$tool_dir" ]; then
        pushd "$tool_dir" > /dev/null
        echo "Installing $repo_name into the Galaxy environment..."
        if pip install . ; then
            echo "Successfully installed $repo_name"
        else
            echo "Failed to install $repo_name"
        fi
        popd > /dev/null
    else
        echo "Directory $tool_dir does not exist, skipping installation"
    fi
done

# Return to initial directory and deactivate venv
cd "$initial_dir"
deactivate

echo "Installation complete"