#!/bin/sh
set -e

echo "📦 Starting CI post-clone setup"

# Go to repository root
cd "$(dirname "$0")/.."
REPO_ROOT=$(pwd)

echo "Repository root: $REPO_ROOT"

# Install Flutter if not available
if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$REPO_ROOT/flutter"
  export PATH="$REPO_ROOT/flutter/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

echo "Running flutter pub get"
flutter pub get

echo "Installing CocoaPods"
cd ios
pod install --repo-update

echo "✅ CI setup completed"
