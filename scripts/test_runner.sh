#!/bin/bash
set -e

echo "=== Test Runner ==="
echo ""

# Parse arguments
TEST_TYPE="${1:-all}"
REPORT="${2:-false}"

run_ios_tests() {
    echo "Running iOS tests..."
    make test-ios
    echo "✓ iOS tests complete"
}

run_android_tests() {
    echo "Running Android tests..."
    make test-android
    echo "✓ Android tests complete"
}

generate_report() {
    local report_dir="test-reports"
    mkdir -p "$report_dir"
    
    echo "Generating test reports..."
    
    if [ -f "ios/test-report.txt" ]; then
        cp ios/test-report.txt "$report_dir/ios.txt"
    fi
    
    if [ -f "android/test-report.txt" ]; then
        cp android/test-report.txt "$report_dir/android.txt"
    fi
    
    echo "Reports saved to $report_dir/"
}

case "$TEST_TYPE" in
    ios)
        run_ios_tests
        ;;
    android)
        run_android_tests
        ;;
    all)
        run_ios_tests
        run_android_tests
        ;;
    *)
        echo "Invalid test type: $TEST_TYPE. Use 'ios', 'android', or 'all'"
        exit 1
        ;;
esac

if [ "$REPORT" == "true" ]; then
    generate_report
fi

echo ""
echo "=== Test Summary ==="
echo "All tests completed successfully!"