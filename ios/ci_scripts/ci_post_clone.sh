#!/bin/sh
set -e

echo "Installing Flutter dependencies..."

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

flutter --version

echo "Running flutter pub get"
flutter pub get

echo "Installing CocoaPods"
cd ../../ios
pod install
cd ..
