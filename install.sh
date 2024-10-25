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

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

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

# Install MySQL Client
echo "Installing MySQL client..."
sudo apt install -y mysql-client

# Install Node.js 20
echo "Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
echo "Installing PM2..."
sudo npm install -g pm2

# Run Composer Install
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install Imagick
echo "Installing Imagick extension for PHP 8.1..."
sudo apt install -y php-imagick

# Update php.ini settings
echo "Updating PHP configuration in $PHP_INI..."
sudo sed -E -i 's/upload_max_filesize = .*/upload_max_filesize = 3G/' $PHP_INI
sudo sed -E -i 's/post_max_size = .*/post_max_size = 1G/' $PHP_INI
sudo sed -E -i 's/memory_limit = .*/memory_limit = 4G/' $PHP_INI
sudo sed -E -i 's/max_input_time = .*/max_input_time = 120/' $PHP_INI
sudo sed -E -i 's/max_execution_time = .*/max_execution_time = 300/' $PHP_INI

# Restart PHP-FPM to apply changes
echo "Restarting PHP-FPM service to apply Imagick extension..."
sudo systemctl restart php8.1-fpm

# Verification step
if php -m | grep -q 'imagick'; then
    echo "Imagick installation verified successfully!"
else
    echo "Imagick installation failed or is not enabled."
fi

echo "Installation and configuration completed successfully!"
