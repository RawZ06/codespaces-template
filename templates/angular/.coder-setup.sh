#!/bin/bash
set -e

echo "Installing Angular CLI globally..."
npm install -g @angular/cli

echo "Installing dependencies..."
pnpm install

echo "Setup complete! Run 'pnpm start' to start development server."
