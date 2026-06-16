#!/bin/bash
# ==============================================================================
# Build and Package Script for CleanMacKeyboard
# ==============================================================================
# This script compiles the macOS application in Release mode and packages it
# into both a .zip file and a .dmg image for distribution.
# ==============================================================================

set -e

# Configuration
PROJECT_NAME="cleanyourmackeyboard"
SCHEME_NAME="cleanyourmackeyboard"
CONFIGURATION="Release"
BUILD_DIR="./build_output"
EXPORT_DIR="$BUILD_DIR/exported"
ZIP_NAME="CleanMacKeyboard.zip"
DMG_NAME="CleanMacKeyboard.dmg"

echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -f "$ZIP_NAME"
rm -f "$DMG_NAME"

echo "🏗️ Building Xcode project in ${CONFIGURATION} mode..."
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
           -scheme "${SCHEME_NAME}" \
           -configuration "${CONFIGURATION}" \
           -derivedDataPath "${BUILD_DIR}/DerivedData" \
           clean build

# Find the built .app package
BUILT_APP_PATH="${BUILD_DIR}/DerivedData/Build/Products/${CONFIGURATION}/CleanYourMacKeyboard.app"

if [ ! -d "$BUILT_APP_PATH" ]; then
    # Try finding it in case of different folder structure
    BUILT_APP_PATH=$(find "${BUILD_DIR}/DerivedData" -name "CleanYourMacKeyboard.app" -type d | head -n 1)
fi

if [ -z "$BUILT_APP_PATH" ] || [ ! -d "$BUILT_APP_PATH" ]; then
    echo "❌ Error: Built CleanYourMacKeyboard.app not found!"
    exit 1
fi

echo "🔍 Found built app at: $BUILT_APP_PATH"

echo "📦 Packaging app into ZIP..."
mkdir -p "$EXPORT_DIR"
cp -R "$BUILT_APP_PATH" "$EXPORT_DIR/"

cd "$EXPORT_DIR"
zip -q -r "../../${ZIP_NAME}" "CleanYourMacKeyboard.app"
cd - > /dev/null
echo "✅ ZIP package created: ${ZIP_NAME}"

echo "📦 Packaging app into DMG..."
# Create a temp directory for DMG contents
DMG_TEMP="$BUILD_DIR/dmg_temp"
mkdir -p "$DMG_TEMP"
cp -R "$BUILT_APP_PATH" "$DMG_TEMP/"
# Create symbolic link to /Applications inside the DMG
ln -s /Applications "$DMG_TEMP/Applications"

hdiutil create -volname "CleanMacKeyboard" -srcfolder "$DMG_TEMP" -ov -format UDZO "${BUILD_DIR}/${DMG_NAME}"
mv "${BUILD_DIR}/${DMG_NAME}" "./"
echo "✅ DMG package created: ${DMG_NAME}"


echo "=============================================================================="
echo "🎉 Build & Packaging Successful!"
echo "Files ready for release:"
echo "  1. ${ZIP_NAME}  (Compact archive)"
echo "  2. ${DMG_NAME}  (Installable disk image)"
echo "=============================================================================="
