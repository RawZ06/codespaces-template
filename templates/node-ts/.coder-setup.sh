#!/bin/bash
set -e

echo "Installing dependencies..."
pnpm install

echo "Building project..."
pnpm build

echo "Setup complete! Run 'pnpm dev' to start development."
