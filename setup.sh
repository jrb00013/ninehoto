#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== ninehoto setup ==="

# Detect platform
PLATFORM="$(uname)"
IS_MACOS=false
IS_LINUX=false
IS_ANDROID_SDK_SET=false

if [[ "$PLATFORM" == "Darwin" ]]; then
    IS_MACOS=true
    echo "[+] macOS detected"
elif [[ "$PLATFORM" == "Linux" ]]; then
    IS_LINUX=true
    echo "[+] Linux detected"
else
    echo "[!] Windows (WSL recommended): treat as Linux"
    IS_LINUX=true
fi

# Check for required tools
check_tool() {
    if command -v "$1" &>/dev/null; then
        echo "[+] $1: $(command -v $1)"
    else
        echo "[!] $1: not found"
        return 1
    fi
}

# --- iOS setup ---
setup_ios() {
    echo ""
    echo "=== iOS setup ==="

    if ! "$IS_MACOS"; then
        echo "[~] iOS builds require macOS. Skipping."
        return 0
    fi

    local failed=0

    if ! check_tool xcodegen; then
        echo "[~] XcodeGen not found. Install: brew install xcodegen"
        failed=1
    fi

    if ! check_tool xcodebuild; then
        echo "[~] xcodebuild not found. Install Xcode from App Store."
        failed=1
    fi

    if ! check_tool swift; then
        echo "[~] Swift not found."
        failed=1
    fi

    if command -v swift &>/dev/null; then
        local swift_ver
        swift_ver=$(swift --version | head -1)
        echo "[+] Swift: $swift_ver"
    fi

    if command -v xcodebuild &>/dev/null; then
        local xcode_ver
        xcode_ver=$(xcodebuild -version 2>&1 | head -1)
        echo "[+] Xcode: $xcode_ver"
    fi

    # Check simulators
    echo ""
    echo "[*] Available iOS simulators:"
    xcrun simctl list devices available 2>/dev/null | head -30 || echo "  (no simulators found)"

    if command -v xcodegen &>/dev/null; then
        echo ""
        echo "[*] Generating Xcode project..."
        cd ios
        xcodegen generate && echo "[+] ios/Ninehoto.xcodeproj generated" || echo "[!] xcodegen failed"
        cd ..
    fi

    if command -v xcodebuild &>/dev/null && [[ -f ios/Ninehoto.xcodeproj ]]; then
        echo ""
        echo "[*] Checking iOS project build..."
        xcodebuild -project ios/Ninehoto.xcodeproj -scheme Ninehoto -configuration Debug -destination 'generic platform=iOS Simulator' build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5 || echo "[!] iOS build check failed"
    fi

    echo ""
    echo "[*] iOS setup complete."
    echo "[*] To run: open ios/Ninehoto.xcodeproj"
}

# --- Android setup ---
setup_android() {
    echo ""
    echo "=== Android setup ==="

    local failed=0

    if ! check_tool java 2>/dev/null; then
        echo "[~] Java not found. Install: brew install openjdk@17 (macOS) or apt install openjdk-17-jdk (Linux)"
        failed=1
    fi

    if command -v java &>/dev/null; then
        local java_ver
        java_ver=$(java -version 2>&1 | head -1)
        echo "[+] Java: $java_ver"
    fi

    if ! check_tool dotnet 2>/dev/null; then
        echo "[~] .NET not found. Install: https://dotnet.microsoft.com/download"
        failed=1
    fi

    if command -v dotnet &>/dev/null; then
        local dotnet_ver
        dotnet_ver=$(dotnet --version)
        echo "[+] .NET: $dotnet_ver"
    fi

    # Android SDK
    local sdk_path=""
    local sdk_paths=(
        "$HOME/Library/Android/sdk"
        "$HOME/Android/Sdk"
        "/usr/local/lib/android/sdk"
        "/opt/android-sdk"
        "$ANDROID_HOME"
        "$ANDROID_SDK_ROOT"
    )

    for p in "${sdk_paths[@]}"; do
        if [[ -d "$p" ]]; then
            sdk_path="$p"
            break
        fi
    done

    if [[ -n "$sdk_path" ]]; then
        echo "[+] Android SDK: $sdk_path"
        echo "sdk.dir=$sdk_path" > android/local.properties
        echo "[+] Updated android/local.properties"

        if [[ -d "$sdk_path/platforms" ]]; then
            echo "[*] Installed platforms:"
            ls "$sdk_path/platforms" 2>/dev/null | head -5 || echo "  (none)"
        fi
        if [[ -d "$sdk_path/build-tools" ]]; then
            echo "[*] Installed build tools:"
            ls "$sdk_path/build-tools" 2>/dev/null | head -5 || echo "  (none)"
        fi
        if [[ -d "$sdk_path/cmdline-tools" ]]; then
            echo "[*] cmdline-tools available"
        fi
    else
        echo "[!] Android SDK not found."
        echo "[*] Searched paths: ${sdk_paths[*]}"
        echo "[*] Install from: https://developer.android.com/studio"
        echo "[*] Then set sdk.dir= in android/local.properties"
        failed=1
    fi

    # Gradle wrapper
    echo ""
    if [[ -f android/gradlew ]]; then
        echo "[+] Gradle wrapper found"
    else
        echo "[!] Gradle wrapper missing"
        failed=1
    fi

    if [[ -f android/gradle/wrapper/gradle-wrapper.jar ]]; then
        echo "[+] Gradle wrapper JAR found"
    else
        echo "[!] Gradle wrapper JAR missing"
        failed=1
    fi

    if command -v dotnet &>/dev/null && [[ -n "$sdk_path" ]]; then
        echo ""
        echo "[*] Checking Android project build..."
        cd android
        ./gradlew tasks --quiet 2>&1 | tail -3 || echo "[!] Gradle check failed (expected if deps missing)"
        cd ..
    fi

    echo ""
    echo "[*] Android setup complete."
}

# --- Emulator setup ---
setup_emulators() {
    echo ""
    echo "=== Emulator setup ==="

    if ! "$IS_MACOS"; then
        echo "[~] Android emulator setup requires macOS. Skipping."
        return 0
    fi

    # Android emulator
    local android_sdk=""
    for p in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "/usr/local/lib/android/sdk"; do
        if [[ -d "$p" ]]; then
            android_sdk="$p"
            break
        fi
    done

    if [[ -n "$android_sdk" && -d "$android_sdk/cmdline-tools/latest/bin" ]]; then
        local avdmanager="$android_sdk/cmdline-tools/latest/bin/avdmanager"
        local emulator="$android_sdk/emulator/emulator"

        if [[ -f "$avdmanager" ]]; then
            echo "[*] avdmanager available"
            echo ""
            echo "[*] Existing AVDs:"
            "$avdmanager" list avd 2>/dev/null | head -20 || echo "  (none)"

            echo ""
            echo "[*] Creating 'ninehoto_test' AVD if not exists..."
            if "$avdmanager" list avd 2>/dev/null | grep -q "ninehoto_test"; then
                echo "[+] ninehoto_test AVD already exists"
            else
                echo "y" | "$avdmanager" create avd --name ninehoto_test --package "system-images;android-34;google_apis;x86_64" --device "pixel_6" 2>&1 | tail -10 || echo "[!] AVD creation may have failed (check SDK)"
            fi
        fi
    else
        echo "[!] Android SDK cmdline-tools not found at $android_sdk/cmdline-tools"
        echo "[*] Install via Android Studio SDK Manager or:"
        echo "    sdkmanager --install 'cmdline-tools;latest' 'platforms;android-34' 'build-tools;34.0.0' 'system-images;android-34;google_apis;x86_64'"
    fi

    # iOS simulators
    if "$IS_MACOS" && command -v xcrun &>/dev/null; then
        echo ""
        echo "[*] iOS simulators:"
        xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | head -10 || echo "  (none)"
    fi
}

# --- Tests ---
setup_tests() {
    echo ""
    echo "=== Test setup ==="

    if "$IS_MACOS" && command -v xcodebuild &>/dev/null; then
        echo "[*] iOS tests: xcodebuild test command ready"
        echo "    xcodebuild test -project ios/Ninehoto.xcodeproj -scheme Ninehoto"
    fi

    if command -v dotnet &>/dev/null; then
        echo "[*] Android tests: dotnet test command ready"
        echo "    cd android/Ninehoto.Android && dotnet test"
    fi
}

# Run all
setup_ios
setup_android
setup_emulators
setup_tests

echo ""
echo "=== Done ==="
echo "Next steps:"
echo "  iOS:    open ios/Ninehoto.xcodeproj"
echo "  Android: cd android && ./gradlew installDebug"
