# Architecture

ninehoto is two native apps sharing one design: a swipe deck over recent media, a session that collects pending deletions, and an OS-native confirmation before anything is removed. No data leaves the device.

## Shared concepts

| Concept | iOS | Android |
|---|---|---|
| Media model | `Models/MediaItem.swift` | `MediaItem.cs`, `Models/` |
| Library access | `PhotoLibraryService` | `MediaRepository` |
| Session state | `SwipeSessionViewModel` | `ViewModels/`, `MainActivity` |
| Thumbnail cache (LRU + prefetch) | `ThumbnailCache` | `ThumbnailCache.cs` |
| Duplicate/burst grouping | `Utilities/DuplicateDetector.swift` | `Models/AssetGroup.cs` |
| Trip filtering | `Utilities/TripDetector.swift` | `Models/Trip.cs` |
| Feature flags | `Utilities/FeatureFlags.swift` | `Utilities/FeatureFlags.cs` |

## iOS (`ios/`)

- `NinehotoApp` → `RootView` → `MainMenuView` / `SwipeDeckView`
- `Views/` and `Views/Components/` hold reusable SwiftUI pieces (e.g. `FullscreenMediaView`, `FilterSelectionView`)
- `Protocols/` define service interfaces so tests can inject fakes
- Project file is generated from `project.yml` with XcodeGen

## Android (`android/`)

- `MainActivity` hosts the deck; `SettingsActivity`, `StatisticsActivity`, `AboutActivity` are secondary screens
- `Services/`, `Interfaces/`, `Utilities/` mirror the iOS split

## Flow

1. Request photo/media permission
2. Load recent items (optionally filtered by trip/location, grouped by burst/duplicate)
3. Swipe left = mark for deletion, right = keep; undo is unlimited per session
4. Finish → show count and freed-space estimate → OS delete prompt

## Build & CI

`make ci` runs the full pipeline locally; `.github/workflows/ci.yml` builds and tests both platforms (macOS runner for iOS).
