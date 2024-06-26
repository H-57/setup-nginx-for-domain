#!/bin/bash

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo." 
   exit 1
fi

# Check if Nginx is installed, if not install it
if ! command -v nginx &> /dev/null
then
    echo "Nginx is not installed. Installing Nginx..."
    apt update
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Nginx installed and started."
else
    echo "Nginx is already installed."
fi

# Rest of your original script goes here
# ...

# Prompt for domain name
read -p "Enter the domain name: " domain

# Prompt for source (proxy_pass)
read -p "Enter the source (proxy_pass, e.g., http://localhost:3000): " proxy_pass

# Create the configuration file
config_file="/etc/nginx/sites-available/$domain"

cat > "$config_file" <<EOL
server {
    listen 80;
    server_name $domain;
    location / {
        proxy_pass $proxy_pass;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

echo "Configuration file created: $config_file"

# Create a symbolic link in the sites-enabled directory
ln -s "$config_file" "/etc/nginx/sites-enabled/$domain"

echo "Symbolic link created in sites-enabled directory."

# Test the Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx

echo "Nginx configuration reloaded."
