#!/bin/bash
set -e

echo "Installing Composer dependencies..."
composer install

echo "Setup complete! Run 'php -S localhost:8000 -t public' to start development server."
