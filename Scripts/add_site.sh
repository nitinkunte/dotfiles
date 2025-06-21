#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Determine Homebrew prefix
HOMEBREW_PREFIX=$(brew --prefix)

# Check if NGINX is installed via Homebrew
if ! brew list | grep -q nginx; then
    echo "NGINX is not installed. Installing NGINX via Homebrew..."
    brew install nginx
fi

# Define paths based on Homebrew prefix
nginx_conf_dir="$HOMEBREW_PREFIX/etc/nginx"
sites_available="$nginx_conf_dir/sites-available"
sites_enabled="$nginx_conf_dir/sites-enabled"
www_root="$HOMEBREW_PREFIX/var/www"

# Create directories if they don't exist
mkdir -p "$sites_available"
mkdir -p "$sites_enabled"
sudo mkdir -p "$www_root"

# Prompt for site name and port
read -p "Enter the site name (e.g., site1): " sitename
read -p "Enter the port number for the application (e.g., for Open Web UI it is 3000): " port

# Create site directory in www_root
site_dir="$www_root/$sitename"
sudo mkdir -p "$site_dir"

# Create NGINX configuration file
config_file="$sites_available/$sitename.conf"
echo "Creating configuration file: $config_file"

cat <<EOL | sudo tee "$config_file"
server {
    listen 80;
    server_name $sitename.local; # or your domain

    location / {
        proxy_pass http://localhost:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-ForwardedProto \$scheme;
    }
}
EOL

# Enable the site by creating a symlink in sites-enabled
sudo ln -s "$config_file" "$sites_enabled/$sitename.conf"

# Test NGINX configuration
echo "Testing NGINX configuration..."
sudo nginx -t

# Reload NGINX to apply changes
echo "Reloading NGINX..."
sudo nginx -s reload

echo "Setup complete. You can access your site at http://$local_ip:$port"

## Update hosts file for local testing
#hosts_entry="127.0.0.1 $sitename.local"
#if ! grep -q "$hosts_entry" /etc/hosts; then
#    sudo sh -c "echo '$hosts_entry' >> /etc/hosts"
#fi
#
#echo "Setup complete. You can access your site at http://$sitename.local"
