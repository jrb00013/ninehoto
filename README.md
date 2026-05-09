# Ninehoto

Swipe-based photo/video cleanup app for Android and iOS.

Swipe left to mark for deletion, right to keep. Nothing is deleted until you confirm.

## Android

**Prerequisites:** Android SDK (API 24+), .NET 8 SDK

```bash
cd android

# Configure your Android SDK path in local.properties:
# sdk.dir=/path/to/android/sdk

# Build debug APK
./gradlew assembleDebug

# Install and run on a connected device/emulator
./gradlew installDebug
```

The APK will be at `Ninehoto.Android/bin/Debug/net8.0-android/apk/debug/Ninehoto.Android.apk`

## iOS

**Prerequisites:** Xcode 15+, XcodeGen

```bash
cd ios

# Generate the Xcode project (only needed if you change .yml or add/remove source files)
xcodegen generate

# Open in Xcode and run on a simulator or device
open Ninehoto.xcodeproj
```

Or build from command line:
```bash
xcodebuild -project Ninehoto.xcodeproj -scheme Ninehoto -configuration Debug -destination 'generic platform=iOS Simulator' build
```
