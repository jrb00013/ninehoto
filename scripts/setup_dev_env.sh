#!/bin/bash
set -e

echo "=== Ninehoto Development Environment Setup ==="
echo ""

check_command() {
    if command -v "$1" &>/dev/null; then
        echo "✓ $1 found"
        return 0
    else
        echo "✗ $1 not found"
        return 1
    fi
}

echo "Checking system dependencies..."

MISSING_DEPS=()

check_command "git" || MISSING_DEPS+=("git")
check_command "make" || MISSING_DEPS+=("make")
check_command "bash" || MISSING_DEPS+=("bash")

echo ""
echo "=== iOS Dependencies ==="
if [[ "$OSTYPE" == "darwin"* ]]; then
    check_command "xcodegen" || MISSING_DEPS+=("xcodegen")
    check_command "swift" || MISSING_DEPS+=("swift")
else
    echo "⚠ iOS development requires macOS"
fi

echo ""
echo "=== Android Dependencies ==="
check_command "java" || MISSING_DEPS+=("java")
check_command "gradle" || MISSING_DEPS+=("gradle")

if [ -n "$ANDROID_HOME" ]; then
    echo "✓ Android SDK found at: $ANDROID_HOME"
else
    echo "⚠ ANDROID_HOME not set"
fi

if [ -n "$JAVA_HOME" ]; then
    echo "✓ Java found at: $JAVA_HOME"
else
    echo "⚠ JAVA_HOME not set"
fi

echo ""
echo "=== Installation ==="
if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    echo "All dependencies found!"
else
    echo "Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    echo "To install on macOS:"
    echo "  brew install ${MISSING_DEPS[*]}"
    echo ""
    echo "To install on Linux:"
    echo "  apt-get update && apt-get install -y ${MISSING_DEPS[*]}"
fi

echo ""
echo "=== Verification ==="

echo "Verifying iOS project..."
if [ -f "ios/project.yml" ]; then
    echo "✓ iOS project.yml found"
else
    echo "✗ iOS project.yml not found"
fi

echo "Verifying Android project..."
if [ -f "android/build.gradle" ]; then
    echo "✓ Android build.gradle found"
else
    echo "✗ Android build.gradle not found"
fi

echo "Verifying Makefile..."
if [ -f "Makefile" ]; then
    echo "✓ Makefile found"
else
    echo "✗ Makefile not found"
fi

echo ""
echo "=== Quick Start ==="
echo "Run 'make setup' to install dependencies"
echo "Run 'make build-all' to build both platforms"
echo "Run 'make test-all' to run all tests"

echo ""
echo "Setup complete!"