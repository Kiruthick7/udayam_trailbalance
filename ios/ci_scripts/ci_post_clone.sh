#!/bin/sh
set -e

echo "📦 Starting CI post-clone setup"

# Always start from the repo root
cd "$CI_WORKSPACE"

# ---- Flutter Setup ----
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not found. Installing Flutter..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable
  export PATH="$PATH:$CI_WORKSPACE/flutter/bin"
fi

echo "Flutter version:"
flutter --version

# ---- Fetch Dart/Flutter dependencies ----
echo "Running flutter pub get"
flutter pub get

# ---- iOS setup ----
echo "Installing CocoaPods dependencies"
cd ios
pod install --repo-update

echo "✅ CI setup completed successfully"
