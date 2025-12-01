# Welcome to the Galaxy Fluxomics workflow project!

This guide will help you install a local deployment of the Galaxy fluxomics workflow evelopped by the MetaboHUB-MetaToul-FluxoMet & MetaSys teams from the Toulouse Biotechnology Institute. It is meant for development and maintainance purposes. This guide assumes you have some working knowledge of git, bash and the galaxy workflow manager. You must have Python 3 installed on your system (see python.org for information on how to install Python).

This project is built on several separate python tools. To ensure ease of maintainance, git submodules are used to be able to easily switch between worklow-level development and specific tool development. More information on git submodules can be found here: https://git-scm.com/book/en/v2/Git-Tools-Submodules and here: https://github.blog/open-source/git/working-with-submodules/.

Lastly, the galaxy instance is meant to run on linux machines. If you are running Windows, it will not work, and it has not been tested on MacOS in the scope of this project. It is thus recommended to run this workflow on a linux system (fully fledged or Virtual Machine).

# Getting started

The first step is to clone the repository onto your local machine:

git clone https://github.com/MetaboHUB-MetaToul-FluxoMet/tools_w4m.git

Navigate to the cloned folder:

cd tools_w4m

A few folders are present in the repository. The Galaxy folder is a git submodule linked to the main galaxy  repository. The commit identifier that references the version that was cloned can be found in the GitHub repository online 

## Run the install script for the tool packages

The next step is to download the latest versions of the tools used in the workflow and install them into the galaxy virtual environment. This is done through the "install_packages.sh" script found in the 




