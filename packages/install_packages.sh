#!/bin/bash

# Save initial directory
initial_dir=$(pwd)
repo_root=$(git rev-parse --show-toplevel)

# List of package names (must match submodule paths in .gitmodules)
packages=(
    "PhysioFit"
    "PhysioFit_Data_Manager"
    "Isoplot"
    "influx_data_manager"
    "IsoCor"
    "influx"
    "Skyline2IsoCor"
)

# Initialize and update all submodules from .gitmodules
echo "Initializing and updating submodules..."
cd "$repo_root"
git submodule update --init --recursive

# Optional: update submodules to latest remote commits
# Uncomment the following line if you want to pull latest changes
# git submodule update --remote --recursive

cd "$initial_dir"

# Check if a virtual environment path was provided or use default
VENV_PATH="${GALAXY_VENV:-$repo_root/galaxy/.venv}"

if [ -f "$VENV_PATH/bin/activate" ]; then
    echo "Activating virtual environment at $VENV_PATH..."
    source "$VENV_PATH/bin/activate"
else
    echo "Warning: Virtual environment not found at $VENV_PATH"
    echo "Set GALAXY_VENV environment variable or create the venv first."
    echo "Skipping pip installations."
    exit 0
fi

# Install each tool into the Galaxy environment
for package in "${packages[@]}"; do
    tool_dir="$initial_dir/$package"
    
    if [ -d "$tool_dir" ]; then
        pushd "$tool_dir" > /dev/null
        echo "Installing $package into the Galaxy environment..."
        if pip install . ; then
            echo "Successfully installed $package"
        else
            echo "Failed to install $package"
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