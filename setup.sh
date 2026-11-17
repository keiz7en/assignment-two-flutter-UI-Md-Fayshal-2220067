#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
command -v flutter >/dev/null || { echo 'Install Flutter and add its bin directory to PATH.'; exit 1; }
flutter doctor
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
echo 'Setup complete. Connect a device and run: flutter run'
