#!/bin/bash
set -e

echo "========================================="
echo "   Ninehoto Development Workflow"
echo "========================================="
echo ""

show_menu() {
    echo "Select an action:"
    echo "1. Setup environment"
    echo "2. Build iOS"
    echo "3. Build Android"
    echo "4. Build all"
    echo "5. Run iOS tests"
    echo "6. Run Android tests"
    echo "7. Run all tests"
    echo "8. Lint iOS"
    echo "9. Lint Android"
    echo "10. Clean all"
    echo "11. Full CI pipeline"
    echo "12. Run iOS simulator"
    echo "13. Run Android emulator"
    echo "0. Exit"
    echo ""
}

setup_environment() {
    echo "Setting up environment..."
    make setup
    echo "✓ Environment setup complete"
}

build_ios() {
    echo "Building iOS..."
    make build-ios
    echo "✓ iOS build complete"
}

build_android() {
    echo "Building Android..."
    make build-android
    echo "✓ Android build complete"
}

build_all() {
    echo "Building all platforms..."
    make build-all
    echo "✓ All builds complete"
}

test_ios() {
    echo "Running iOS tests..."
    make test-ios
    echo "✓ iOS tests complete"
}

test_android() {
    echo "Running Android tests..."
    make test-android
    echo "✓ Android tests complete"
}

test_all() {
    echo "Running all tests..."
    make test-all
    echo "✓ All tests complete"
}

lint_ios() {
    echo "Linting iOS..."
    make lint-ios || true
    echo "✓ iOS lint complete"
}

lint_android() {
    echo "Linting Android..."
    make lint-android || true
    echo "✓ Android lint complete"
}

clean_all() {
    echo "Cleaning all..."
    make clean
    echo "✓ Clean complete"
}

full_ci() {
    echo "Running full CI pipeline..."
    make ci
    echo "✓ CI pipeline complete"
}

run_ios_simulator() {
    echo "Starting iOS simulator..."
    bash scripts/simulator_manager.sh open
    echo "✓ iOS simulator opened"
}

run_android_emulator() {
    echo "Starting Android emulator..."
    bash scripts/emulator_manager.sh start || echo "⚠ Emulator may need setup first"
    echo "✓ Android emulator started"
}

while true; do
    show_menu
    read -p "Enter choice: " choice
    echo ""
    
    case $choice in
        1) setup_environment ;;
        2) build_ios ;;
        3) build_android ;;
        4) build_all ;;
        5) test_ios ;;
        6) test_android ;;
        7) test_all ;;
        8) lint_ios ;;
        9) lint_android ;;
        10) clean_all ;;
        11) full_ci ;;
        12) run_ios_simulator ;;
        13) run_android_emulator ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice, please try again." ;;
    esac
    
    echo ""
    echo "------------------------------------------"
    echo ""
done