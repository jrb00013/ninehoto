#!/bin/bash
set -e

SIMULATOR_NAME="iPhone 15"

list_devices() {
    echo "Available iOS simulators:"
    xcrun simctl list devices available | grep -E "iPhone|iPad" | head -20
}

boot_device() {
    echo "Booting simulator: $SIMULATOR_NAME"
    xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || echo "Already booted or not found"
    xcrun simctl bootstatus "$SIMULATOR_NAME" -b
}

shutdown_device() {
    echo "Shutting down simulator: $SIMULATOR_NAME"
    xcrun simctl shutdown "$SIMULATOR_NAME" 2>/dev/null || true
}

open_ui() {
    echo "Opening Simulator app"
    open -a Simulator
}

install_app() {
    local app_path=$1
    if [ -z "$app_path" ]; then
        echo "Usage: $0 install <app_path>"
        exit 1
    fi
    
    echo "Installing app: $app_path"
    xcrun simctl install booted "$app_path"
    echo "App installed"
}

launch_app() {
    local bundle_id=$1
    if [ -z "$bundle_id" ]; then
        echo "Usage: $0 launch <bundle_id>"
        exit 1
    fi
    
    echo "Launching app: $bundle_id"
    xcrun simctl launch booted "$bundle_id"
}

list_apps() {
    echo "Installed apps:"
    xcrun simctl list apps booted 2>/dev/null || echo "No apps found"
}

erase_device() {
    echo "Erasing simulator: $SIMULATOR_NAME"
    xcrun simctl erase "$SIMULATOR_NAME"
    echo "Simulator erased"
}

create_iphone_15() {
    echo "Creating iPhone 15 simulator"
    
    if xcrun simctl list devices available | grep -q "iPhone 15"; then
        echo "iPhone 15 already exists"
        return 0
    fi
    
    xcrun simctl create "iPhone 15" \
        com.apple.CoreSimulator.SimDeviceType.iPhone-15 \
        com.apple.CoreSimulator.SimRuntime.iOS-17-0 2>/dev/null || true
    
    echo "iPhone 15 created"
}

pair_device() {
    echo "Pairing Watch device (if available)"
    xcrun simctl pair 00001234-0000123400000000 booted 2>/dev/null || echo "No watch to pair"
}

enable_biometrics() {
    echo "Enabling biometric authentication"
    xcrun simctl biometric enroll booted 2>/dev/null || true
}

disable_biometrics() {
    echo "Disabling biometric authentication"
    xcrun simctl biometric unenroll booted 2>/dev/null || true
}

set_location() {
    echo "Setting location to Cupertino, CA"
    xcrun simctl location booted set "37.3230,-122.0322" "Cupertino, CA"
}

reset_location() {
    echo "Resetting location"
    xcrun simctl location booted reset 2>/dev/null || true
}

get_logs() {
    echo "Getting device logs"
    xcrun simctl spawn booted log show --last 5m 2>/dev/null | tail -50
}

case "${1:-}" in
    list)
        list_devices
        ;;
    boot)
        boot_device
        ;;
    shutdown)
        shutdown_device
        ;;
    open)
        open_ui
        ;;
    install)
        install_app "$2"
        ;;
    launch)
        launch_app "$2"
        ;;
    apps)
        list_apps
        ;;
    erase)
        erase_device
        ;;
    create)
        create_iphone_15
        ;;
    pair)
        pair_device
        ;;
    biometrics-enable)
        enable_biometrics
        ;;
    biometrics-disable)
        disable_biometrics
        ;;
    location)
        set_location
        ;;
    location-reset)
        reset_location
        ;;
    logs)
        get_logs
        ;;
    *)
        echo "Usage: $0 {list|boot|shutdown|open|install <path>|launch <bundle>|apps|erase|create|pair|biometrics-enable|biometrics-disable|location|location-reset|logs}"
        exit 1
        ;;
esac