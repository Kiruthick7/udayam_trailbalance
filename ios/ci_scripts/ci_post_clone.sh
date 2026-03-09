#!/bin/sh
set -e

echo "Running flutter pub get"
cd $CI_WORKSPACE
flutter pub get

echo "Installing CocoaPods"
cd $CI_WORKSPACE/ios
pod install
