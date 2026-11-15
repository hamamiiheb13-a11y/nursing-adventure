#!/bin/bash
# Cloudflare Pages Build Script for Flutter Web
set -e

echo "=== Nursing Adventure - Cloudflare Pages Build ==="

# Check if Flutter is already installed in the container
if ! command -v flutter &> /dev/null
then
    echo "Flutter not detected in PATH. Installing Flutter stable..."
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter
    export PATH="$PATH:/tmp/flutter/bin"
fi

echo "Flutter version:"
flutter --version

echo "Fetching project dependencies..."
flutter pub get

echo "Building production release for Flutter Web..."
flutter build web --release

echo "=== Build finished successfully! Output in build/web ==="
