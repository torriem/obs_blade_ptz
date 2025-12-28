#!/bin/bash

# Script to build a standalone executable that serves the Flutter web app

set -e  # Exit on error

echo "Building OBS Blade standalone server..."
echo ""

# Step 1: Build Flutter web app
echo "Step 1/4: Building Flutter web app..."
flutter build web --release
echo "✓ Flutter web build complete"
echo ""

# Step 2: Get dependencies for server
echo "Step 2/4: Getting server dependencies..."
cd server
dart pub get
cd ..
echo "✓ Server dependencies installed"
echo ""

# Step 3: Compile server to executable
echo "Step 3/4: Compiling server to executable..."
cd server
dart compile exe server.dart -o ../dist/obs_blade_server
cd ..
echo "✓ Server compiled"
echo ""

# Step 4: Copy web files to dist
echo "Step 4/4: Copying web files..."
mkdir -p dist/web
cp -r build/web/* dist/web/
echo "✓ Web files copied"
echo ""

echo "=========================================="
echo "Build complete!"
echo ""
echo "Files are in the 'dist' folder:"
echo "  - obs_blade_server (executable)"
echo "  - web/ (Flutter web app files)"
echo ""
echo "To run the server:"
echo "  cd dist"
echo "  ./obs_blade_server [port]"
echo ""
echo "Default port is 8080"
echo "Example: ./obs_blade_server 3000"
echo "=========================================="
