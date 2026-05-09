# ninehoto

> Swipe left to lose it, right to keep it. Nothing is deleted until you confirm.

[![CI](https://github.com/ninehoto/ninehoto/actions/workflows/ci.yml/badge.svg)](https://github.com/ninehoto/ninehoto/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: iOS](https://img.shields.io/badge/Platform-iOS-000000?style=flat&logo=apple)](https://developer.apple.com)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android)](https://developer.android.com)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![C#](https://img.shields.io/badge/C%23-12-512BD4?style=flat&logo=csharp)](https://learn.microsoft.com/en-us/dotnet/csharp)

A dual-platform photo and video cleanup app for iOS and Android. Browse your most recent photos and videos in a Tinder-style swipe interface, mark items for deletion, and confirm when you're ready to clean house.

## Features

- **Swipe interface** — swipe left to mark for deletion, right to keep
- **Haptic feedback** — subtle vibration on every swipe
- **Thumbnail caching** — fast image loading with LRU cache and prefetching
- **Undo** — undo the last swipe (unlimited within a session)
- **Video support** — video duration indicator badges on video cards
- **Delete confirmation** — OS-native delete prompt, nothing removed until you confirm
- **Dark mode** — fully dark UI throughout
- **iOS fullscreen preview** — tap any card to view fullscreen
- **Delete progress indicator** — visual feedback during deletion

## Architecture

```
ninehoto/
├── android/              # Android app (Xamarin/C#)
│   └── Ninehoto.Android/
│       ├── MainActivity.cs
│       ├── MediaRepository.cs
│       ├── MediaItem.cs
│       ├── ThumbnailCache.cs
│       └── Resources/
├── ios/                  # iOS app (SwiftUI)
│   ├── Ninehoto/
│   │   ├── NinehotoApp.swift
│   │   ├── RootView.swift
│   │   ├── MainMenuView.swift
│   │   ├── SwipeDeckView.swift
│   │   ├── SwipeSessionViewModel.swift
│   │   ├── PhotoLibraryService.swift
│   │   ├── ThumbnailCache.swift
│   │   └── FullscreenMediaView.swift
│   ├── NinehotoTests/    # iOS unit tests (XCTest)
│   └── Ninehoto.xcodeproj/
├── .github/
│   ├── workflows/        # GitHub Actions CI
│   ├── ISSUE_TEMPLATE/   # Bug report & feature request
│   └── PULL_REQUEST_TEMPLATE.md
├── Makefile              # Build orchestration
├── setup.sh             # Environment setup script
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── LICENSE
```

## Getting Started

### Prerequisites

| Platform | Requirements |
|----------|--------------|
| iOS | macOS, Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen) |
| Android | macOS/Linux, Java 17+, [.NET 8](https://dotnet.microsoft.com/download), Android SDK (API 24+) |

### Quick Start

```bash
# Clone the repo
git clone https://github.com/ninehoto/ninehoto.git
cd ninehoto

# Run the setup script (checks all dependencies)
./setup.sh

# Or use Make
make setup
```

### iOS

```bash
cd ios

# Generate the Xcode project (only needed once or after source changes)
xcodegen generate

# Open in Xcode
open Ninehoto.xcodeproj

# Or build from command line
xcodebuild -project Ninehoto.xcodeproj -scheme Ninehoto \
  -configuration Debug \
  -destination 'generic platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build

# Run tests
xcodebuild test -project Ninehoto.xcodeproj -scheme Ninehoto \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Android

```bash
cd android

# Configure your SDK path in local.properties:
# sdk.dir=/path/to/android/sdk

# Build debug APK
./gradlew assembleDebug

# Install on a connected device/emulator
./gradlew installDebug

# Run tests
cd Ninehoto.Android
dotnet test
```

## Make Targets

```bash
make setup           # Full environment setup
make build-ios      # Build iOS app
make build-android  # Build Android APK
make build-all      # Build both platforms
make test-ios       # Run iOS tests
make test-android   # Run Android tests
make test-all       # Run all tests
make run-ios        # Run iOS app
make run-android    # Install and run Android app
make clean          # Clean build artifacts
make ci             # Full CI pipeline
```

## Testing

- **iOS**: XCTest via `xcodebuild test`
- **Android**: xUnit via `dotnet test`

Test on both platforms before submitting a PR. On Android, test with at least one pre-Android 11 (API < 30) and one post-Android 11 device for storage compatibility.

## Privacy

ninehoto only requests photo library access to display and delete media you explicitly mark. No media is uploaded anywhere — all processing happens on-device. No analytics or third-party SDKs that transmit data.

See [SECURITY.md](SECURITY.md) for details.

## License

MIT — see [LICENSE](LICENSE)
