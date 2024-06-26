#!/bin/bash

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo." 
   exit 1
fi

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
