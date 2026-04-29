#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="DdayPalette"
DMG_NAME="DdayPalette.dmg"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR/dmg"

xcodebuild \
  -project "$ROOT_DIR/DdayPalette.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Debug \
  -destination "platform=macOS" \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Debug/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App not found at $APP_PATH" >&2
  exit 1
fi

cp -R "$APP_PATH" "$DIST_DIR/dmg/"
ln -s /Applications "$DIST_DIR/dmg/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DIST_DIR/dmg" \
  -ov \
  -format UDZO \
  "$DIST_DIR/$DMG_NAME"

echo "$DIST_DIR/$DMG_NAME"
