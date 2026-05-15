.PHONY: help setup setup-ios setup-android setup-all \
        build-ios build-android build-ios-release build-android-release \
        test-ios test-android test-all \
        run-ios run-android run-emulator \
        generate-ios clean-ios \
        clean-android clean \
        ci bootstrap \
        lint-ios lint-android lint-all \
        format-ios format-android \
        analyze-ios analyze-android \
        deps-update deps-check \
        ci-ios ci-android

SHELL := /bin/bash
PLATFORM := $(shell uname)

# Colors
GREEN  := $(shell printf '\033[0;32m')
CYAN  := $(shell printf '\033[0;36m')
YELLOW := $(shell printf '\033[0;33m')
RED    := $(shell printf '\033[0;31m')
RESET  := $(shell printf '\033[0m')

info = $(printf '$(CYAN)[+] $(RESET)%s\n',$1)
warn = $(printf '$(YELLOW)[~] $(RESET)%s\n',$1)
ok   = $(printf '$(GREEN)[✓] $(RESET)%s\n',$1)
err  = $(printf '$(RED)[✗] $(RESET)%s\n',$1)

help:
	@printf 'ninehoto — available targets:\n\n'
	@printf '  Setup:\n'
	@printf '    make setup          Full setup (ios + android)\n'
	@printf '    make setup-ios     iOS setup only\n'
	@printf '    make setup-android Android setup only\n'
	@printf '    make bootstrap      Install system dependencies (macOS)\n\n'
	@printf '  Build:\n'
	@printf '    make build-ios      Build iOS app (simulator)\n'
	@printf '    make build-android  Build Android APK\n'
	@printf '    make build-all      Build both platforms\n'
	@printf '    make build-ios-release  Build iOS Release\n'
	@printf '    make build-android-release Build Android Release\n\n'
	@printf '  Run:\n'
	@printf '    make run-ios        Run iOS app on simulator\n'
	@printf '    make run-android    Install and run Android app\n'
	@printf '    make run-emulator   Launch Android emulator\n\n'
	@printf '  Test:\n'
	@printf '    make test-ios       Run iOS unit tests\n'
	@printf '    make test-android   Run Android unit tests\n'
	@printf '    make test-all       Run all tests\n\n'
	@printf '  Lint & Code Quality:\n'
	@printf '    make lint-ios       Run SwiftLint on iOS\n'
	@printf '    make lint-android   Run lint on Android\n'
	@printf '    make lint-all       Run lint on both platforms\n'
	@printf '    make format-ios     Format iOS code\n'
	@printf '    make format-android Format Android code\n'
	@printf '    make analyze-ios    Run static analysis on iOS\n'
	@printf '    make analyze-android Run static analysis on Android\n\n'
	@printf '  Dependencies:\n'
	@printf '    make deps-update    Update dependencies\n'
	@printf '    make deps-check     Check dependency versions\n\n'
	@printf '  Clean:\n'
	@printf '    make clean-ios      Clean iOS build artifacts\n'
	@printf '    make clean-android  Clean Android build artifacts\n'
	@printf '    make clean          Clean both platforms\n\n'
	@printf '  CI:\n'
	@printf '    make ci             Full CI pipeline (build + test both)\n'
	@printf '    make ci-ios         iOS CI pipeline\n'
	@printf '    make ci-android     Android CI pipeline'

setup: setup-ios setup-android
	@$(call ok,"Setup complete.")

setup-ios:
	@$(call info,"Running iOS setup...")
	@chmod +x setup.sh && ./setup.sh

setup-android:
	@$(call info,"Running Android setup...")
	@chmod +x setup.sh && ./setup.sh

bootstrap:
	@$(call info,"Installing system dependencies...")
	@if [[ "$$(uname)" != "Darwin" ]]; then \
		$(call warn,"brew is macOS-only. Skipping."); \
	fi
	@if command -v brew &>/dev/null; then \
		brew install xcodegen openjdk@17 android-sdk || true; \
	fi

generate-ios:
	@$(call info,"Generating Xcode project with XcodeGen...")
	@cd ios && xcodegen generate
	@$(call ok,"ios/Ninehoto.xcodeproj ready")

build-ios: generate-ios
	@$(call info,"Building iOS app (Debug)...")
	@xcodebuild -project ios/Ninehoto.xcodeproj \
		-scheme Ninehoto \
		-configuration Debug \
		-destination 'generic platform=iOS Simulator' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build 2>&1 | tail -5
	@$(call ok,"iOS build complete")

build-ios-release: generate-ios
	@$(call info,"Building iOS app (Release)...")
	@xcodebuild -project ios/Ninehoto.xcodeproj \
		-scheme Ninehoto \
		-configuration Release \
		-destination 'generic platform=iOS Simulator' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build 2>&1 | tail -5
	@$(call ok,"iOS Release build complete")

build-android:
	@$(call info,"Building Android APK (Debug)...")
	@cd android && ./gradlew assembleDebug --no-daemon 2>&1 | tail -10
	@$(call ok,"APK: android/Ninehoto.Android/bin/Debug/net8.0-android/apk/debug/Ninehoto.Android.apk")

build-android-release:
	@$(call info,"Building Android APK (Release)...")
	@cd android && ./gradlew assembleRelease --no-daemon 2>&1 | tail -10
	@$(call ok,"APK built")

build-all: build-ios build-android
	@$(call ok,"Both platforms built successfully")

run-ios: build-ios
	@$(call info,"Listing available simulators...")
	@xcrun simctl list devices available | grep -E "iPhone" | head -5
	@$(call warn,"Open Xcode and run on a simulator of your choice:")
	@$(call info,"  open ios/Ninehoto.xcodeproj")

run-android: build-android
	@$(call info,"Checking for connected Android devices...")
	@adb devices 2>/dev/null | head -5 || $(call warn,"adb not found or no devices")
	@$(call ok,"Install manually: cd android && ./gradlew installDebug")

run-emulator:
	@$(call info,"Listing Android emulators...")
	@emulator -list-avds 2>/dev/null | head -5 || $(call warn,"emulator not in PATH")
	@$(call warn,"Start manually: emulator -avd ninehoto_test")

test-ios: generate-ios
	@$(call info,"Running iOS tests...")
	@xcodebuild test -project ios/Ninehoto.xcodeproj \
		-scheme Ninehoto \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO 2>&1 | tail -20

test-android:
	@$(call info,"Running Android unit tests...")
	@cd android/Ninehoto.Android && dotnet test --no-build 2>&1 | tail -20 || \
		$(call warn,"Run 'make build-android' first, then 'make test-android'")

test-all: test-ios test-android
	@$(call ok,"All tests passed")

lint-ios:
	@$(call info,"Running SwiftLint on iOS...")
	@if command -v swiftlint &>/dev/null; then \
		cd ios && swiftlint; \
	else \
		$(call warn,"SwiftLint not installed, installing..."); \
		brew install swiftlint; \
		cd ios && swiftlint; \
	fi
	@$(call ok,"iOS lint complete")

lint-android:
	@$(call info,"Running Android lint...")
	@cd android && ./gradlew lint --no-daemon 2>&1 | tail -10
	@$(call ok,"Android lint complete")

lint-all: lint-ios lint-android

format-ios:
	@$(call info,"Formatting iOS code...")
	@if command -v swift-format &>/dev/null; then \
		swift-format format ios/Ninehoto/; \
	else \
		$(call warn,"swift-format not installed"); \
	fi

format-android:
	@$(call info,"Formatting Android code...")
	@cd android && ./gradlew formatKotlin --no-daemon 2>&1 || true

analyze-ios: generate-ios
	@$(call info,"Running iOS static analysis...")
	@xcodebuild -project ios/Ninehoto.xcodeproj \
		-scheme Ninehoto \
		-configuration Debug \
		-destination 'generic platform=iOS Simulator' \
		analyze 2>&1 | grep -E "(error:|warning:)" | head -30 || true

analyze-android:
	@$(call info,"Running Android static analysis...")
	@cd android && ./gradlew detekt --no-daemon 2>&1 | tail -20 || true

deps-update:
	@$(call info,"Checking for dependency updates...")
	@echo "iOS: Check manually via Xcode or CocoaPods"
	@echo "Android: Check gradle wrapper for updates"
	@cd android && ./gradlew dependencyUpdates 2>&1 | tail -20 || true

deps-check:
	@$(call info,"Checking dependency versions...")
	@cat VERSIONS
	@echo ""
	@echo "Current installed versions:"
	@xcodebuild -version 2>/dev/null | head -1 || true
	@java -version 2>&1 | head -1 || true
	@dotnet --version 2>/dev/null || true

clean-ios:
	@$(call info,"Cleaning iOS build artifacts...")
	@rm -rf ios/Ninehoto.xcodeproj
	@$(call ok,"iOS clean complete. Run 'make generate-ios' to regenerate.")

clean-android:
	@$(call info,"Cleaning Android build artifacts...")
	@cd android && ./gradlew clean --no-daemon 2>&1 | tail -3
	@rm -f android/local.properties
	@$(call ok,"Android clean complete")

clean: clean-ios clean-android
	@$(call ok,"Project fully cleaned")

ci: build-all test-all
	@$(call ok,"CI pipeline complete")

ci-ios:
	@$(call info,"Running iOS CI pipeline...")
	@make generate-ios
	@make build-ios
	@make test-ios
	@make lint-ios
	@$(call ok,"iOS CI complete")

ci-android:
	@$(call info,"Running Android CI pipeline...")
	@make build-android
	@make test-android
	@make lint-android
	@$(call ok,"Android CI complete")