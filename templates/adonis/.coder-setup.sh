#!/bin/bash
set -e

echo "Copying .env file..."
cp .env.example .env

echo "Installing dependencies..."
pnpm install

echo "Setup complete! Run 'node ace serve --hmr' to start development server."
