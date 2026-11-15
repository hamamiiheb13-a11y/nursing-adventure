#!/bin/bash
# Cloudflare Pages Build Script for Flutter Web
set -e

echo "=== Nursing Adventure - Cloudflare Pages Automated Build ==="

# 1. Ensure git safe directory on CI environments
git config --global --add safe.directory "*"

# 2. Check and install Flutter SDK
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
    echo "Installing Flutter SDK (stable channel)..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# 3. Configure Flutter
echo "Configuring Flutter for Web..."
flutter config --no-analytics
flutter config --enable-web

echo "Flutter version:"
flutter --version

# 4. Fetch dependencies
echo "Fetching project dependencies..."
flutter pub get

# 5. Build Flutter Web release
echo "Compiling Flutter Web release to build/web..."
flutter build web --release

# 6. Ensure Cloudflare _headers file is present in build/web
if [ -f "web/_headers" ]; then
    cp web/_headers build/web/_headers
fi

echo "=== Build finished successfully! Output verified in build/web ==="
ls -la build/web
