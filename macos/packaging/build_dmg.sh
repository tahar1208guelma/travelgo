#!/bin/bash
# Script to package TRAVELGO.app into TRAVELGO.dmg on macOS environment with create-dmg / hdiutil
set -e

APP_NAME="TRAVELGO"
BUILD_DIR="build/macos/Build/Products/Release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_DIR="build/macos/Build/Products/Release/dmg"
DMG_PATH="build/macos/Build/Products/Release/${APP_NAME}.dmg"

if [ ! -d "${APP_BUNDLE}" ]; then
  echo "Error: ${APP_BUNDLE} not found. Please run 'flutter build macos --release' first on macOS."
  exit 1
fi

echo "Packaging ${APP_BUNDLE} into ${DMG_PATH}..."
rm -rf "${DMG_DIR}" "${DMG_PATH}"
mkdir -p "${DMG_DIR}"
cp -R "${APP_BUNDLE}" "${DMG_DIR}/"
ln -s /Applications "${DMG_DIR}/Applications"

hdiutil create -volname "${APP_NAME}" -srcfolder "${DMG_DIR}" -ov -format UDZO "${DMG_PATH}"
echo "Successfully created ${DMG_PATH}"
