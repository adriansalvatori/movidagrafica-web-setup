#!/bin/bash

set -e

echo -e "\033[35m======================="
echo -e "Movidagráfica Web Project Set-up"
echo -e "=======================\033[0m"

# Ask for project name
echo "Enter project name (use dashes instead of spaces):"
read project_name

# Ask for theme name
echo "Enter theme name (use dashes instead of spaces):"
read theme_name

# Create new Bedrock project
echo -e "\033[35mCreating new Bedrock project...\033[0m"
composer create-project roots/bedrock "$project_name"

# Move into project folder
cd "$project_name"

# Change web folder name to public_html
echo "Changing web folder name to public_html..."
mv web public_html

# Change webroot_dir in config/application.php
echo "Updating webroot_dir in config/application.php..."
sed -i "" 's/$webroot_dir = $root_dir . "\/web";/$webroot_dir = $root_dir . "\/public_html";/' config/application.php

# Create new Alma theme
echo -e "\033[35m Creating new Alma theme... \033[0m"
cd public_html/app/themes/
composer create-project salvatori/alma "$theme_name" dev-master

# Rename Alma theme
echo "Renaming Alma theme..."
cd ./"$theme_name"

# Replace placeholders in style.css
echo "Updating theme information in style.css..."
sed -i "" "s/Theme Name: Alma/Theme Name: $theme_name/" "style.css"
sed -i "" "s/Theme URI: https:\/\/github.com\/Salvatori\/alma/Theme URI: https:\/\/github.com\/Salvatori\/$theme_name/" "style.css"
sed -i "" "s/Description: Alma Theme/Description: $theme_name Theme/" "style.css"
sed -i "" "s/Version: 1.0.0/Version: 0.1.0/" "style.css"
sed -i "" "s/Author: Salvatori/Author: Movidagráfica/" "style.css"
sed -i "" "s/Author URI: https:\/\/github.com\/Salvatori/Author URI: https:\/\/github.com\/movidagrafica/" "style.css"
sed -i "" "s/Alma/$theme_name/" "style.css"

# Initialize git repository
echo -e "\033[35m Initializing git repository...\033[0m"
cd ../../../../
git init

# Create .env file
echo "Creating .env file..."
cp .env.example .env

# Generate salts
echo "Generating .env data and salts..."
# Prompt for database variables
read -p "Database name: " DB_NAME
read -p "Database user: " DB_USER
read -p "Database password: " DB_PASSWORD

# Prompt for optional database variables
read -p "Database host (optional): " DB_HOST
read -p "Database prefix (optional): " DB_PREFIX

# Prompt for WordPress variables
read -p "WordPress environment: " WP_ENV
read -p "WordPress home URL: " WP_HOME

# Prompt for optional WordPress variable
read -p "Debug log path (optional): " WP_DEBUG_LOG

# Generate salts
AUTH_KEY=$(curl -s https://roots.io/salts.html | grep -o "define('AUTH_KEY', '[^']*')" | sed "s/define('AUTH_KEY', '\(.*\)')/\1/")
SECURE_AUTH_KEY=$(curl -s https://roots.io/salts.html | grep -o "define('SECURE_AUTH_KEY', '[^']*')" | sed "s/define('SECURE_AUTH_KEY', '\(.*\)')/\1/")
LOGGED_IN_KEY=$(curl -s https://roots.io/salts.html | grep -o "define('LOGGED_IN_KEY', '[^']*')" | sed "s/define('LOGGED_IN_KEY', '\(.*\)')/\1/")
NONCE_KEY=$(curl -s https://roots.io/salts.html | grep -o "define('NONCE_KEY', '[^']*')" | sed "s/define('NONCE_KEY', '\(.*\)')/\1/")
AUTH_SALT=$(curl -s https://roots.io/salts.html | grep -o "define('AUTH_SALT', '[^']*')" | sed "s/define('AUTH_SALT', '\(.*\)')/\1/")
SECURE_AUTH_SALT=$(curl -s https://roots.io/salts.html | grep -o "define('SECURE_AUTH_SALT', '[^']*')" | sed "s/define('SECURE_AUTH_SALT', '\(.*\)')/\1/")
LOGGED_IN_SALT=$(curl -s https://roots.io/salts.html | grep -o "define('LOGGED_IN_SALT', '[^']*')" | sed "s/define('LOGGED_IN_SALT', '\(.*\)')/\1/")
NONCE_SALT=$(curl -s https://roots.io/salts.html | grep -o "define('NONCE_SALT', '[^']*')" | sed "s/define('NONCE_SALT', '\(.*\)')/\1/")

# Write to .env file
echo "DB_NAME='$DB_NAME'" > .env
echo "DB_USER='$DB_USER'" >> .env
echo "DB_PASSWORD='$DB_PASSWORD'" >> .env

if [ ! -z "$DB_HOST" ]; then
    echo "DB_HOST='$DB_HOST'" >> .env
fi

if [ ! -z "$DB_PREFIX" ]; then
    echo "DB_PREFIX='$DB_PREFIX'" >> .env
fi

echo "WP_ENV='$WP_ENV'" >> .env
echo "WP_HOME='$WP_HOME'" >> .env
echo "WP_SITEURL='${WP_HOME}/wp'" >> .env

if [ ! -z "$WP_DEBUG_LOG" ]; then
    echo "WP_DEBUG_LOG='$WP_DEBUG_LOG'" >> .env
fi

echo "AUTH_KEY='$AUTH_KEY'" >> .env
echo "SECURE_AUTH_KEY='$SECURE_AUTH_KEY'" >> .env

# Set up GitHub Action for autodeployment to cPanel
echo -e "\033[35mSetting up GitHub Action for autodeployment to cPanel...\033[0m"
echo "Enter FTP username:"
read ftp_username
echo "Enter FTP password:"
read ftp_password
echo "Enter FTP server:"
read ftp_server
# Replace webroot_dir in config/application.php
sed -i '' 's/$webroot_dir = $root_dir . "\/web";/$webroot_dir = $root_dir . "\/public_html";/g' ./config/application.php

# Ask for GitHub credentials
read -p "Enter your GitHub username: " github_username
read -p "Enter your GitHub repository name: " github_repo_name
read -sp "Enter your GitHub personal access token: " github_token
echo ""


# Set up GitHub repository
echo -e "\033[35m Setting up GitHub repository...\033[0m"
curl -u $github_username:$github_token https://api.github.com/user/repos -d "{\"name\":\"$github_repo_name\"}"
git remote add origin git@github.com:$github_username/$github_repo_name.git
git add .
git commit -m "Initial commit"
git push -u origin main

# Set up GitHub action for auto-deployment
echo -e "\033[35mSetting up GitHub action for auto-deployment...\033[0m"
mkdir -p .github/workflows
cat <<EOT >> .github/workflows/deploy.yml
on: push
name: 🚀 Deploy web-app on push
jobs:
  web-deploy:
    name: 🎉 Deploy
    runs-on: ubuntu-latest
    steps:
    - name: 🚚 Get latest code
      uses: actions/checkout@v3
    
    - name: 📂 Sync files
      uses: SamKirkland/FTP-Deploy-Action@4.3.3
      with:
        server: $ftp_server
        username: $ftp_username
        password: $ftp_password
EOT

# Commit and push changes
echo "Committing changes and pushing to GitHub..."
git add .
git commit -m "Set up auto-deployment with GitHub action"
git push

echo -e "\033[35mDone! Your Movidagráfica web project is ready to go."