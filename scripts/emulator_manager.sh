#!/bin/bash
set -e

EMULATOR_NAME="ninehoto_test"
AVD_CONFIG="nexus_5x_api_34"

command -v emulator &>/dev/null || {
    echo "Android emulator not found. Please install Android SDK tools."
    exit 1
}

create_emulator() {
    echo "Creating Android emulator: $EMULATOR_NAME"
    
    if avdmanager list avds | grep -q "$EMULATOR_NAME"; then
        echo "Emulator $EMULATOR_NAME already exists"
        return 0
    fi
    
    echo "y" | avdmanager create avd \
        --name "$EMULATOR_NAME" \
        --package "system-images;android-34;google_apis;x86_64" \
        --device "Nexus 5X" 2>/dev/null || true
    
    echo "Emulator created successfully"
}

start_emulator() {
    echo "Starting Android emulator: $EMULATOR_NAME"
    
    emulator -avd "$EMULATOR_NAME" \
        -noaudio \
        -no-window \
        -gpu swiftshader_indirect \
        -no-boot-anim \
        -wipe-data &
    
    echo "Waiting for emulator to boot..."
    await_emulator_boot
}

await_emulator_boot() {
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
            echo "Emulator booted successfully"
            return 0
        fi
        sleep 2
        ((attempt++))
        echo "Waiting... ($attempt/$max_attempts)"
    done
    
    echo "Warning: Emulator boot timeout, continuing anyway"
    return 0
}

stop_emulator() {
    echo "Stopping Android emulator"
    adb emu kill 2>/dev/null || true
}

list_emulators() {
    echo "Available Android emulators:"
    avdmanager list avds 2>/dev/null | grep -E "Name:|Device:|Target:" || echo "No emulators found"
}

install_apk() {
    local apk_path=$1
    if [ -z "$apk_path" ]; then
        echo "Usage: $0 install <apk_path>"
        exit 1
    fi
    
    echo "Installing APK: $apk_path"
    adb install -r "$apk_path"
    echo "APK installed"
}

case "${1:-}" in
    create)
        create_emulator
        ;;
    start)
        start_emulator
        ;;
    stop)
        stop_emulator
        ;;
    list)
        list_emulators
        ;;
    install)
        install_apk "$2"
        ;;
    *)
        echo "Usage: $0 {create|start|stop|list|install <apk>}"
        echo ""
        echo "Commands:"
        echo "  create              Create Android emulator"
        echo "  start              Start Android emulator"
        echo "  stop               Stop Android emulator"
        echo "  list               List available emulators"
        echo "  install <apk>      Install APK to running emulator"
        exit 1
        ;;
esac