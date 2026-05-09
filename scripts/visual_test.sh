# Visual regression test runner
# Usage: ./scripts/visual_test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== ninehoto visual regression tests ==="
echo ""

IOS_SIMULATOR="${IOS_SIMULATOR:-iPhone 15}"
ANDROID_AVD="${ANDROID_AVD:-ninehoto_test}"

# iOS
test_ios() {
    echo "[*] Running iOS visual tests on simulator: $IOS_SIMULATOR"

    if [[ "$(uname)" != "Darwin" ]]; then
        echo "[!] iOS tests require macOS"
        return 1
    fi

    echo "[*] Generating Xcode project..."
    cd "$PROJECT_ROOT/ios"
    xcodegen generate 2>&1 | tail -3

    echo "[*] Building app..."
    xcodebuild -project Ninehoto.xcodeproj \
        -scheme Ninehoto \
        -configuration Debug \
        -destination "platform=iOS Simulator,name=$IOS_SIMULATOR" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        build 2>&1 | tail -3

    echo "[+] iOS app built successfully"
    echo "[*] Manually verify UI in simulator"
    echo "    open Ninehoto.xcodeproj"
}

# Android
test_android() {
    echo ""
    echo "[*] Running Android visual tests on AVD: $ANDROID_AVD"

    local sdk_path=""
    for p in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "/usr/local/lib/android/sdk"; do
        if [[ -d "$p" ]]; then
            sdk_path="$p"
            break
        fi
    done

    if [[ -z "$sdk_path" ]]; then
        echo "[!] Android SDK not found"
        return 1
    fi

    local emulator="$sdk_path/emulator/emulator"
    if [[ ! -f "$emulator" ]]; then
        echo "[!] Android emulator not found at $emulator"
        return 1
    fi

    echo "[*] Starting emulator: $ANDROID_AVD"
    "$emulator" -avd "$ANDROID_AVD" -no-window -no-audio &
    sleep 5

    echo "[*] Building APK..."
    cd "$PROJECT_ROOT/android"
    ./gradlew assembleDebug --no-daemon 2>&1 | tail -3

    local apk
    apk=$(find "$PROJECT_ROOT/android" -name "*.apk" -type f 2>/dev/null | head -1)
    if [[ -n "$apk" ]]; then
        echo "[+] APK: $apk"
        echo "[*] Installing on emulator..."
        adb install -r "$apk" 2>&1 | tail -3
        echo "[*] Launching app..."
        adb shell am start -n com.ninehoto.app/.MainActivity
    fi

    echo "[*] Emulator left running in background."
    echo "[*] Manually verify UI on emulator."
    echo "[*] To stop: adb emu kill"
}

# Run
if [[ "${1:-all}" == "ios" ]]; then
    test_ios
elif [[ "${1:-all}" == "android" ]]; then
    test_android
else
    test_ios
    test_android
fi

echo ""
echo "[*] Done."
