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

## Code Style

- **Swift**: Swift 5.9+, follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). Enable Format On Save in Xcode.
- **C#**: C# 12+, follow [Microsoft's C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions).
- **Android XML**: 4-space indentation, `android:` prefix on all attributes.

## Branching Strategy

- `main` — stable release
- `develop` — integration branch (when needed)
- `feat/*` — new features
- `fix/*` — bug fixes
- `chore/*` — tooling, deps, docs

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add swipe undo button
fix: resolve thumbnail cache eviction on Android
chore: update AndroidX.CardView to 1.0.0.25
docs: add contributing guide
```

## Pull Requests

1. Fork the repo and create a feature branch from `main`
2. Make your changes with passing builds on both platforms
3. Open a PR with a clear description
4. Link any related issues with `Closes #N` or `Fixes #N`

## Reporting Issues

Use the [bug report template](./.github/ISSUE_TEMPLATE/bug_report.md) or [feature request template](./.github/ISSUE_TEMPLATE/feature_request.md).

## Testing

Test on both platforms before submitting. On Android, test with:
- At least one API 24–27 device (legacy storage)
- At least one API 33+ device (scoped storage)

On iOS, test with both `.authorized` and `.limited` photo authorization states.
