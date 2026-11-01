#!/usr/bin/env bash
# Render Build Script for FixIT Django Backend
# This script is executed by Render during the build phase.

set -o errexit  # Exit on any error

echo "==> Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "==> Collecting static files..."
python manage.py collectstatic --no-input

echo "==> Running database migrations..."
python manage.py migrate

echo "==> Build complete!"
