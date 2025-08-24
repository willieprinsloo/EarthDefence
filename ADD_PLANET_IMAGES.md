# 🌍 How to Add Your Planet Images

## Quick Steps:

1. **Open Finder** and navigate to:
   `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/`

2. **For each planet folder**, drag and drop your PNG images:

   📁 **planet-earth.imageset/**
   - Add your Earth image and rename it to: `planet-earth.png`
   
   📁 **planet-mars.imageset/**
   - Add your Mars image and rename it to: `planet-mars.png`
   
   📁 **planet-jupiter.imageset/**
   - Add your Jupiter image and rename it to: `planet-jupiter.png`
   
   📁 **planet-venus.imageset/**
   - Add your Venus image and rename it to: `planet-venus.png`
   
   📁 **planet-moon.imageset/**
   - Add your Moon image and rename it to: `planet-moon.png`

## Alternative Method - Using Xcode:

1. Open your project in Xcode
2. Click on `Assets.xcassets` in the navigator
3. You'll see the planet imagesets (they'll have warning icons)
4. For each imageset:
   - Drag your planet PNG directly onto the "1x" slot
   - Xcode will automatically copy and rename the file

## After Adding Images:

1. Clean Build Folder: `Cmd + Shift + K`
2. Build and Run: `Cmd + R`
3. Your planets will now display with rotation animations!

## Note:
The images you shared earlier need to be saved as PNG files with transparent backgrounds (or the black background will be visible). If needed, you can use an image editor to remove the black backgrounds first.