#!/bin/bash

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo."
   exit 1
fi

# Check if Nginx is installed, if not install it
if ! command -v nginx &> /dev/null; then
    echo "Nginx is not installed. Installing Nginx..."
    apt update
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Nginx installed and started."
else
    echo "Nginx is already installed."
fi

# Prompt for domain name
read -p "Enter the domain name: " domain

# Prompt for port only
read -p "Enter the port number (e.g., 3000): " port

# Build proxy_pass automatically
proxy_pass="http://localhost:$port"

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

# Enable site
ln -s "$config_file" "/etc/nginx/sites-enabled/$domain"

# Test & reload
nginx -t && systemctl reload nginx

echo "Nginx configuration reloaded."
