#!/bin/bash
set -e

echo "Copying .env file..."
cp .env.example .env

echo "Installing Composer dependencies..."
composer install

echo "Generating application key..."
php artisan key:generate

echo "Creating database file..."
touch database/database.sqlite

echo "Running migrations..."
php artisan migrate

echo "Setup complete! Run 'php artisan serve' to start development server."
