#!/bin/bash
# Generates the Dopamine.xcodeproj using xcodegen
# Install xcodegen: brew install xcodegen
# Then run: ./generate_xcodeproj.sh

set -e

if ! command -v xcodegen &> /dev/null; then
    echo "xcodegen not found. Install with: brew install xcodegen"
    echo "Then re-run this script."
    exit 1
fi

xcodegen generate
echo "Dopamine.xcodeproj generated successfully!"
echo "Open with: open Dopamine.xcodeproj"
