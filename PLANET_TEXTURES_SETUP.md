# Planet Textures Setup Guide

## How to Add Your Planet Images

The game is now configured to use high-quality planet texture images instead of programmatically drawn planets. To enable these textures:

### 1. Copy Your Planet Images

Place your planet PNG images in the following directories:

- **Earth**: `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/planet-earth.imageset/`
  - Filename: `planet-earth.png`

- **Mars**: `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/planet-mars.imageset/`
  - Filename: `planet-mars.png`

- **Jupiter**: `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/planet-jupiter.imageset/`
  - Filename: `planet-jupiter.png`

- **Venus**: `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/planet-venus.imageset/`
  - Filename: `planet-venus.png`

- **Moon**: `/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/planet-moon.imageset/`
  - Filename: `planet-moon.png`

### 2. Image Requirements

- Format: PNG with transparent background
- Recommended size: 1024x1024 pixels or higher for best quality
- The black backgrounds will be treated as transparent automatically

### 3. Features Added

- ✅ Planet sprites with texture support
- ✅ Slow rotation animations (Earth: 60s, Mars: 50s, Jupiter: 30s, Moon: 90s)
- ✅ Atmospheric glow effects preserved
- ✅ Fallback to programmatic drawing if textures not found
- ✅ Proper sizing for each planet type

### 4. Testing

After adding your images:
1. Clean build folder (Cmd+Shift+K in Xcode)
2. Build and run the project
3. Navigate to different maps to see the planet backgrounds

The planets will automatically rotate slowly and display with atmospheric effects for enhanced visual appeal.