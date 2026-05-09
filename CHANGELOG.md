# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2024-05-09

### Added

- Swipe-based photo/video cleanup interface
- **iOS**: SwiftUI app with `SwipeDeckView`, `MainMenuView`, `RootView`
- **Android**: Xamarin/C# app with `MainActivity`, `MediaRepository`, `MediaItem`
- Photo library access with permission handling (iOS `PHAuthorizationStatus`, Android `READ_MEDIA_*`)
- Swipe left to mark for deletion, right to keep
- Haptic feedback on swipe (iOS `UIImpactFeedbackGenerator`, Android `Vibrator`)
- Undo last swipe on both platforms
- Thumbnail caching with LRU eviction and prefetching
- Video duration indicator badges on cards
- DELETE/KEEP overlay badges that fade with swipe progress
- Card scale animation during drag
- Undo button in session view
- Delete confirmation dialog with item count
- Delete progress overlay on Android
- Fullscreen media preview on iOS (tap card)
- Dark branded launch screens (storyboard on iOS, themed activity on Android)
- App icons at all required sizes (iOS 1024×1024, Android mdpi → xxxhdpi)
- Gradle build setup for Android (`gradlew`, `build.gradle`, wrapper properties)
- XcodeGen `project.yml` for iOS
- `README.md` with build instructions
- `LICENSE` (MIT)
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `.gitignore`
- `.editorconfig`
- GitHub Actions CI workflow
- Issue and PR templates
