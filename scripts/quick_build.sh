#!/bin/bash
set -e

echo "=== Quick Build Script ==="
echo ""

# Parse arguments
BUILD_TYPE="${1:-debug}"
PLATFORM="${2:-all}"

case "$BUILD_TYPE" in
    debug)
        CONFIG="Debug"
        ;;
    release)
        CONFIG="Release"
        ;;
    *)
        echo "Invalid build type: $BUILD_TYPE. Use 'debug' or 'release'"
        exit 1
        ;;
esac

case "$PLATFORM" in
    ios)
        echo "Building iOS ($CONFIG)..."
        make build-ios
        echo "✓ iOS build complete"
        ;;
    android)
        echo "Building Android ($CONFIG)..."
        if [ "$CONFIG" == "Debug" ]; then
            make build-android
        else
            make build-android-release
        fi
        echo "✓ Android build complete"
        ;;
    all)
        echo "Building both platforms ($CONFIG)..."
        if [ "$CONFIG" == "Debug" ]; then
            make build-all
        else
            make build-ios-release
            make build-android-release
        fi
        echo "✓ All builds complete"
        ;;
    *)
        echo "Invalid platform: $PLATFORM. Use 'ios', 'android', or 'all'"
        exit 1
        ;;
esac

echo ""
echo "=== Build Artifacts ==="
echo "iOS: ios/Ninehoto.xcodeproj"
echo "Android: android/Ninehoto.Android/bin/"