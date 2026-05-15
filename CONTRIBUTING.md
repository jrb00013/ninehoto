# Contributing to ninehoto

We're glad you want to contribute! Here's how to get started.

## Development Setup

### iOS

1. Clone the repo
2. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
3. Navigate to `ios/` and generate the project: `xcodegen generate`
4. Open `Ninehoto.xcodeproj` in Xcode
5. Select a simulator or device and run

### Android

1. Clone the repo
2. Set your Android SDK path in `android/local.properties`:
   ```
   sdk.dir=/Users/Shared/AndroidSDK
   ```
3. Navigate to `android/`
4. Build: `./gradlew assembleDebug`
5. Install: `./gradlew installDebug`

## Quick Start with Make

```bash
# Full setup
make setup

# Build both platforms
make build-all

# Run tests on both platforms
make test-all

# Run linting
make lint-all
```

## Code Style

- **Swift**: Swift 5.9+, follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). Enable Format On Save in Xcode.
- **C#**: C# 12+, follow [Microsoft's C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions).
- **Android XML**: 4-space indentation, `android:` prefix on all attributes.

## Architecture

This project follows clean architecture principles:

```
ios/Ninehoto/
├── App/           # App entry points
├── Models/       # Data models and business logic
├── Views/        # SwiftUI views
├── ViewModels/   # MVVM view models
├── Services/     # Business logic services
├── Utilities/    # Helpers, managers
├── Protocols/    # Interface definitions
├── Extensions/   # Swift extensions
└── Resources/    # Assets, localization

android/Ninehoto.Android/
├── Models/       # Data models
├── Services/     # Business logic
├── ViewModels/   # MVVM view models
├── Views/        # Activities, fragments
├── Interfaces/   # Interface definitions
└── Utilities/    # Helpers, managers
```

## Branching Strategy

- `main` — stable release
- `develop` — integration branch (when needed)
- `feat/*` — new features
- `fix/*` — bug fixes
- `chore/*` — tooling, deps, docs
- `refactor/*` — code refactoring

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add swipe undo button
fix: resolve thumbnail cache eviction on Android
chore: update AndroidX.CardView to 1.0.0.25
docs: add contributing guide
refactor: move services to new architecture layer
test: add unit tests for SwipeSessionViewModel
```

## Pull Requests

1. Fork the repo and create a feature branch from `main`
2. Make your changes with passing builds on both platforms
3. Run tests on both iOS and Android
4. Run linting (`make lint-all`)
5. Open a PR with a clear description
6. Link any related issues with `Closes #N` or `Fixes #N`

## Testing

Test on both platforms before submitting:
- **Android**: Test with at least one API 24–27 device (legacy storage) and one API 33+ device (scoped storage)
- **iOS**: Test with both `.authorized` and `.limited` photo authorization states

### Running Tests

```bash
# iOS tests
make test-ios

# Android tests
make test-android

# All tests
make test-all
```

## Reporting Issues

Use the [bug report template](./.github/ISSUE_TEMPLATE/bug_report.md) or [feature request template](./.github/ISSUE_TEMPLATE/feature_request.md).

## Feature Flags

The app uses feature flags for gradual rollout and testing:

- iOS: `ios/Ninehoto/Utilities/FeatureFlags.swift`
- Android: `android/Ninehoto.Android/Utilities/FeatureFlags.cs`

## Performance Monitoring

Performance metrics are tracked when debug mode is enabled:

- iOS: `ios/Ninehoto/Utilities/PerformanceMonitor.swift`
- Android: `android/Ninehoto.Android/Utilities/PerformanceMonitor.cs`

## Debug Mode

Enable debug features via:
- iOS: Settings > Debug
- Android: Settings > Debug

## License

By contributing to ninehoto, you agree that your contributions will be licensed under the MIT License.