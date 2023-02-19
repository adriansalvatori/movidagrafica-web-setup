# **Readme**
This Bash script is intended to set up a new WordPress project using the Bedrock boilerplate and Alma theme.

To set up the GitHub action for autodeploying the current project to a server, the following information is required:

- **FTP credentials for the server:** This includes the FTP host, username, and password that will be used to connect to the server and transfer the project files.
- Additionally, the script will require a few other things to be set up in GitHub:

- **GitHub account: **You'll need a GitHub account to create a repository and enable the action for deployment.

- **GitHub Personal Access Token (PAT):** The script will use a PAT to authenticate with GitHub's API when creating the repository and enabling the action. You can generate a PAT by following these instructions from GitHub: Creating a personal access token.
- ** SSH connection with GitHub:**The script will use SSH to connect to GitHub when pushing the code changes to the repository. You can set up an SSH connection with GitHub by following these instructions from GitHub: Connecting to GitHub with SSH.



Once you have all of the required information, the script will take care of creating the repository, enabling the action, and configuring the FTP credentials for autodeploying the current project to the server.

## How to Use
1. Clone the repository to your local machine.
2. Navigate to the directory where you cloned the repository.
3. Run the mg-web-setup.sh script.
4. Enter the project name (using dashes instead of spaces) when prompted.
5. Enter the theme name (using dashes instead of spaces) when prompted.
6. Follow the prompts to enter the necessary database and WordPress variables.
7. Follow the prompts to enter the necessary github and server variables.

## What it Does
The mg-web-setup.sh script does the following:

1. Asks for the project name and theme name.
2. Creates a new Bedrock project using the given project name.
3. Renames the web folder to public_html.
4. Updates the webroot_dir in the config/application.php file to public_html.
5. Creates a new Alma theme using the given theme name.
6. Renames the Alma theme to the given theme name and updates the necessary information in the style.css file.
7. Initializes a new Git repository.
8. Creates a .env file and prompts the user for the necessary database and WordPress variables.
9. Generates salts using the Roots.io Salt Generator and writes them to the .env file.
10. Creates a Github repository with the project contents. 
11. Creates a Github Action to autodeploy the project. 

## Requirements

To use this script, you must have:

- Bash
- Composer
- Git

#### Notes
This script was last tested on Bash version 5.1.4.
This script was last tested on macOS 12.1 (Monterey).