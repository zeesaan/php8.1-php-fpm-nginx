#!/bin/bash

# Exit on error
set -e

# Variables
DOMAIN="example.com"
WEB_ROOT="/var/www/html/$DOMAIN"
PHP_INI="/etc/php/8.1/fpm/php.ini"

# Update and Upgrade System
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install PHP 8.1 and PHP-FPM
echo "Adding PHP repository..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

echo "Installing PHP 8.1 and extensions..."
sudo apt install php8.1 php8.1-fpm php8.1-cli php8.1-mysql php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip php8.1-gd -y

# Check PHP-FPM Status
echo "Starting PHP-FPM service..."
sudo systemctl start php8.1-fpm
sudo systemctl enable php8.1-fpm

# Install Nginx
echo "Installing Nginx..."
sudo apt install nginx -y

# Start and Enable Nginx
echo "Starting Nginx service..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure Nginx
echo "Configuring Nginx for $DOMAIN..."
sudo mkdir -p $WEB_ROOT
sudo tee /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the Server Block
echo "Enabling the server block..."
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Test Nginx Configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Set Permissions
echo "Setting permissions for $WEB_ROOT..."
sudo chown -R www-data:www-data /var/www/$DOMAIN
sudo chmod -R 755 /var/www/$DOMAIN

# Update php.ini settings
echo "Updating PHP configuration in $PHP_INI..."
sudo sed -E -i 's/upload_max_filesize = .*/upload_max_filesize = 3G/' $PHP_INI
sudo sed -E -i 's/post_max_size = .*/post_max_size = 1G/' $PHP_INI
sudo sed -E -i 's/memory_limit = .*/memory_limit = 4G/' $PHP_INI
sudo sed -E -i 's/max_input_time = .*/max_input_time = 120/' $PHP_INI
sudo sed -E -i 's/max_execution_time = .*/max_execution_time = 300/' $PHP_INI

# Restart PHP-FPM to apply changes
echo "Restarting PHP-FPM service..."
sudo systemctl restart php8.1-fpm

echo "Installation and configuration completed successfully!"
