#!/bin/bash
set -e

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Setup complete! Run 'uvicorn main:app --reload' to start development server."
