#!/bin/sh
set -e

echo "📦 Starting CI post-clone setup"

# Go to repository root
cd "$CI_WORKSPACE"

# Install Flutter if not available
if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$CI_WORKSPACE/flutter"
  export PATH="$CI_WORKSPACE/flutter/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

echo "Running flutter pub get"
flutter pub get

echo "Installing CocoaPods"
cd ios
pod install --repo-update

echo "✅ CI setup completed"
