#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== ninehoto visual test runner ==="

PLATFORM="$(uname)"

# --- iOS ---
run_ios() {
    echo "[*] iOS visual test"

    if [[ "$PLATFORM" != "Darwin" ]]; then
        echo "[!] iOS requires macOS"
        return 1
    fi

    if ! command -v xcrun &>/dev/null; then
        echo "[!] xcrun not found (Xcode required)"
        return 1
    fi

    echo "[*] Checking simulators..."
    SIMS=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone (1[4-9]|SE)" | head -5)
    if [[ -z "$SIMS" ]]; then
        echo "[*] No recent iPhone simulators. Listing all:"
        xcrun simctl list devices available 2>/dev/null | grep -E "iPhone" | head -10
        echo "[!] Boot a simulator manually, then run the app from Xcode."
        return 1
    fi

    echo "[+] Available simulators:"
    echo "$SIMS"

    echo "[*] Generating project..."
    cd ios && xcodegen generate && cd ..

    echo "[*] Launching iOS simulator..."
    SIM_NAME=$(echo "$SIMS" | head -1 | sed 's/(.*//' | tr -d ' ')
    echo "[*] Booting: $SIM_NAME"
    xcrun simctl boot "$SIM_NAME" 2>/dev/null || echo "[~] Could not boot $SIM_NAME"

    echo ""
    echo "[*] Open Xcode and run:"
    echo "    open ios/Ninehoto.xcodeproj"
    echo "[*] Then use Xcode to launch on: $SIM_NAME"
}

# --- Android ---
run_android() {
    echo ""
    echo "[*] Android visual test"

    if ! command -v adb &>/dev/null; then
        echo "[!] adb not found (Android SDK required)"
        echo "    Set PATH to include \$ANDROID_HOME/platform-tools"
        return 1
    fi

    local device_count
    device_count=$(adb devices 2>/dev/null | grep -c "device$" || true)
    echo "[*] Connected devices: $device_count"

    if [[ "$device_count" -gt 0 ]]; then
        echo "[+] Devices found:"
        adb devices -l 2>/dev/null | grep "device$" | head -5
    else
        echo "[*] No devices connected."
        echo "[*] Options:"
        echo "    1. Connect an Android device with USB debugging"
        echo "    2. Start an emulator: emulator -avd ninehoto_test"
        echo "    3. Or install SDK manager tools and create one:"
        echo "       sdkmanager 'system-images;android-34;google_apis;x86_64'"
        echo "       avdmanager create avd --name ninehoto_test --package 'system-images;android-34;google_apis;x86_64'"
    fi

    echo ""
    echo "[*] Building APK..."
    cd android && ./gradlew assembleDebug --no-daemon 2>&1 | tail -3 && cd ..

    local apk
    apk=$(find android -name "*.apk" -type f 2>/dev/null | head -1)
    if [[ -n "$apk" ]]; then
        echo "[+] APK: $apk"
        echo "[*] To install: adb install -r '$apk'"
    fi
}

# --- Main ---
if [[ "${1:-}" == "ios" ]]; then
    run_ios
elif [[ "${1:-}" == "android" ]]; then
    run_android
else
    run_ios
    run_android
fi

echo ""
echo "[*] Done."
echo "[*] For full setup: ./setup.sh"
echo "[*] For all build targets: make help"
