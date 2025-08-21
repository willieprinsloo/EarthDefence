#!/bin/bash

echo "🧪 Verifying Map System..."
echo "=========================="

# Check if maps.txt exists
if [ -f "Maps/maps.txt" ]; then
    echo "✅ maps.txt found"
    echo "File size: $(wc -c < Maps/maps.txt) bytes"
    echo ""
    echo "First map preview:"
    head -30 Maps/maps.txt | tail -26
else
    echo "❌ maps.txt not found!"
fi

echo ""
echo "Checking app bundle..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "SpaceSalvagers.app" -type d | grep -v "Index.noindex" | head -1)

if [ -n "$APP_PATH" ]; then
    echo "✅ App bundle found at: $APP_PATH"
    
    if [ -f "$APP_PATH/maps.txt" ]; then
        echo "✅ maps.txt is in app bundle"
    else
        echo "❌ maps.txt NOT in app bundle!"
        echo "Attempting to copy..."
        cp Maps/maps.txt "$APP_PATH/" 2>/dev/null && echo "✅ Copied maps.txt to bundle"
    fi
else
    echo "❌ App bundle not found"
fi

echo ""
echo "Test complete!"