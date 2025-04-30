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

# Add/update submodules
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    submodule_path="$initial_dir/$repo_name"
    
    if git config --file .gitmodules --get-regexp path | grep -q "$repo_name"; then
        echo "Updating submodule $repo_name..."
        git submodule update --remote "$repo_name"
    else
        echo "Checking if $repo_name already exists in index..."
        
        # Check if path already exists in the index
        if git ls-files --error-unmatch "$repo_name" &>/dev/null; then
            echo "Warning: $repo_name already exists in the index. Skipping submodule addition."
        else
            echo "Adding submodule $repo_name..."
            git submodule add "$repo" "$repo_name"
        git submodule update --init --recursive "$repo_name"
        fi
    fi
done

# Activate the Galaxy virtual environment
source /home/llegregam/Documents/tools_w4m/galaxy/.venv/bin/activate

# Install each tool into the Galaxy environment
for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    tool_dir="$initial_dir/$repo_name"
    
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