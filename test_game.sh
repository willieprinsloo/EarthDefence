#!/bin/bash

echo "🎮 Testing Space Salvagers Map System"
echo "======================================"

# Build and install
echo "📦 Building game..."
xcodebuild -project SpaceSalvagers.xcodeproj -scheme SpaceSalvagers -sdk iphonesimulator build > /dev/null 2>&1

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SpaceSalvagers.app" -type d | grep -v "Index.noindex" | head -1)
cp Maps/maps.txt "$APP_PATH/" 2>/dev/null

xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true
xcrun simctl install "iPhone 16 Pro" "$APP_PATH" 2>/dev/null

# Launch and capture logs
echo "🚀 Launching game..."
xcrun simctl launch --console-pty "iPhone 16 Pro" com.willieprinsloo.spacesalvagers.game 2>&1 | head -100 &

# Wait and take screenshot
sleep 5
xcrun simctl io booted screenshot /tmp/game_screenshot.png 2>/dev/null

if [ -f /tmp/game_screenshot.png ]; then
    echo "✅ Screenshot saved to /tmp/game_screenshot.png"
    open /tmp/game_screenshot.png
else
    echo "❌ Screenshot failed"
fi
