#!/bin/bash
set -euo pipefail

# Resolve paths from the script location, so it can be run from anywhere
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(git -C "$script_dir" rev-parse --show-toplevel)

# Initialize and update all submodules from .gitmodules
echo "Initializing and updating submodules..."
git -C "$repo_root" submodule update --init --recursive

# Optional: update submodules to latest remote commits
# Uncomment the following line if you want to pull latest changes
# git -C "$repo_root" submodule update --remote --recursive

# Packages to install: every submodule under packages/ in .gitmodules
mapfile -t packages < <(
    git -C "$repo_root" config -f .gitmodules --get-regexp '^submodule\..*\.path$' \
        | awk '{print $2}' | grep '^packages/'
)

# Check if a virtual environment path was provided or use default
VENV_PATH="${GALAXY_VENV:-$repo_root/galaxy/.venv}"

if [ -f "$VENV_PATH/bin/activate" ]; then
    echo "Activating virtual environment at $VENV_PATH..."
    # shellcheck disable=SC1091
    source "$VENV_PATH/bin/activate"
else
    echo "Error: Virtual environment not found at $VENV_PATH" >&2
    echo "Submodules are ready. Run galaxy/run.sh once to create the virtualenv," >&2
    echo "or set the GALAXY_VENV environment variable, then run this script again." >&2
    exit 1
fi

# Install each tool into the Galaxy environment
failed=()
for package in "${packages[@]}"; do
    tool_dir="$repo_root/$package"

    if [ -d "$tool_dir" ]; then
        echo "Installing $package into the Galaxy environment..."
        if (cd "$tool_dir" && pip install .); then
            echo "Successfully installed $package"
        else
            echo "Failed to install $package" >&2
            failed+=("$package")
        fi
    else
        echo "Directory $tool_dir does not exist" >&2
        failed+=("$package")
    fi
done

deactivate

if [ ${#failed[@]} -gt 0 ]; then
    echo "Installation failed for: ${failed[*]}" >&2
    exit 1
fi
echo "Installation complete"
