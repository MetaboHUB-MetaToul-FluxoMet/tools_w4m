## Overview

This guide will help you install a local deployment of the Galaxy fluxomics workflow developed by the MetaboHUB-MetaToul-FluxoMet & MetaSys teams from the Toulouse Biotechnology Institute. It is intended for development and maintenance purposes.

### Prerequisites

- Working knowledge of Git, Bash, and the Galaxy workflow manager
- Python 3 installed on your system (see [python.org](https://python.org) for installation instructions)
- A Linux system (fully fledged or Virtual Machine)
    - **Note:** The Galaxy instance is designed to run on Linux machines. It will not work on Windows and has not been tested on macOS.

### Project Structure

This project is built on several separate Python tools. Git submodules are used to facilitate easy switching between workflow-level development and specific tool development. For more information on Git submodules, see:
- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Working with Submodules](https://github.blog/open-source/git/working-with-submodules/)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/MetaboHUB-MetaToul-FluxoMet/tools_w4m.git
cd tools_w4m
```

### Repository Structure

The repository contains the following directories:

- **Galaxy**: A Git submodule linked to the main Galaxy repository (currently linked to the 25.0 release). The commit number references the downloaded submodule version.
- **packages**: Contains submodules for each individual tool in the workflow, as well as scripts for updating submodules and installing tools into the Galaxy virtual environment.
- **test-data**: Contains test data for the workflow.
- **tool_wrappers**: Contains XML files for configuring tool execution and GUI display.

### Install Tool Packages

Run the installation script to download the latest versions of the workflow tools and install them into the Galaxy virtual environment:

```bash
cd packages
sh ./install_packages.sh
```

This will install the different software into the galaxy .venv, which can be found at ./galaxy/.venv/.

### Install the wrappers and make the tools visible by galaxy

The next step is to ensure Galaxy has access to the tool XML wrappers. This can be done by following the steps found [here](https://galaxyproject.org/admin/tools/add-tool-tutorial/). The actual tool code is not needed to be copied into the tools directory as it is already installed within the galaxy venv. The most importat step is to make Galaxy aware of the tools by adding them to the tool_conf.xml file.

### Run galaxy

You can now launch the galaxy instance with:

```bash
sh ./galaxy/run.sh
```





