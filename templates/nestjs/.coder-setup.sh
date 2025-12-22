#!/bin/bash
set -e

echo "Installing NestJS CLI globally..."
npm install -g @nestjs/cli

echo "Installing dependencies..."
pnpm install

echo "Building project..."
pnpm build

echo "Setup complete! Run 'pnpm start:dev' to start development server."
