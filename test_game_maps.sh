#!/bin/bash

echo "🎮 Testing Space Salvagers Map System..."

# Build the game
echo "📦 Building for iOS Simulator..."
xcodebuild -project SpaceSalvagers.xcodeproj \
           -scheme SpaceSalvagers \
           -sdk iphonesimulator \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
           clean build 2>&1 | tail -20

# Check build result
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Get the app path
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SpaceSalvagers.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📱 App location: $APP_PATH"
        
        # Check if maps.txt is in the bundle
        if [ -f "$APP_PATH/maps.txt" ]; then
            echo "✅ maps.txt found in app bundle"
            echo "📄 First 20 lines of maps.txt:"
            head -20 "$APP_PATH/maps.txt"
        else
            echo "❌ maps.txt NOT found in app bundle!"
            echo "📁 Bundle contents:"
            ls -la "$APP_PATH/" | head -20
        fi
        
        # Install and run the app
        echo "🚀 Installing app to simulator..."
        xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "Simulator already booted"
        xcrun simctl install "iPhone 15 Pro" "$APP_PATH"
        
        echo "🎮 Launching game..."
        xcrun simctl launch --console "iPhone 15 Pro" com.yourdomain.SpaceSalvagers 2>&1 | head -50
    else
        echo "❌ Could not find built app"
    fi
else
    echo "❌ Build failed!"
fi