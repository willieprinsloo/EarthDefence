#!/bin/bash

# Script to add SimpleVectorMapLoader.swift and vector_maps.txt to Xcode project

echo "🔧 Adding files to Xcode project..."

PROJECT_FILE="SpaceSalvagers.xcodeproj/project.pbxproj"
SWIFT_FILE="SpaceSalvagers/Game/Managers/SimpleVectorMapLoader.swift"
VECTOR_MAPS_FILE="Maps/vector_maps.txt"

# Check if files exist
if [[ ! -f "$SWIFT_FILE" ]]; then
    echo "❌ $SWIFT_FILE not found"
    exit 1
fi

if [[ ! -f "$VECTOR_MAPS_FILE" ]]; then
    echo "❌ $VECTOR_MAPS_FILE not found"
    exit 1
fi

echo "✅ Found $SWIFT_FILE"
echo "✅ Found $VECTOR_MAPS_FILE"

# Copy vector_maps.txt to project bundle
cp "$VECTOR_MAPS_FILE" "SpaceSalvagers/"
echo "📄 Copied vector_maps.txt to SpaceSalvagers/"

# Use ruby to add files to Xcode project
echo "🏗️ Adding files to Xcode project..."

# Create a simple ruby script to modify the pbxproj file
cat > add_to_project.rb << 'EOF'
require 'xcodeproj'

project_path = 'SpaceSalvagers.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'SpaceSalvagers' }
if target.nil?
  puts "❌ Could not find SpaceSalvagers target"
  exit 1
end

# Find the Game/Managers group
managers_group = project.main_group.find_subpath('SpaceSalvagers/Game/Managers', true)

# Add SimpleVectorMapLoader.swift to the Managers group
swift_file_ref = managers_group.new_reference('SimpleVectorMapLoader.swift')
target.source_build_phase.add_file_reference(swift_file_ref)

# Find the SpaceSalvagers group for resources
resources_group = project.main_group.find_subpath('SpaceSalvagers', true)

# Add vector_maps.txt as a resource
resource_file_ref = resources_group.new_reference('vector_maps.txt')
target.resources_build_phase.add_file_reference(resource_file_ref)

# Save the project
project.save

puts "✅ Added SimpleVectorMapLoader.swift to project"
puts "✅ Added vector_maps.txt as resource"
puts "🎉 Files successfully added to Xcode project!"
EOF

# Try to run the ruby script
if command -v xcodeproj &> /dev/null; then
    ruby add_to_project.rb
    rm add_to_project.rb
else
    echo "⚠️ xcodeproj gem not available, adding files manually..."
    
    # Manual approach - just ensure files are in correct locations
    echo "📁 Files are in correct locations:"
    echo "   - SimpleVectorMapLoader.swift: ✅"
    echo "   - vector_maps.txt: ✅"
    echo ""
    echo "🔧 Please manually add these files to Xcode:"
    echo "   1. Open SpaceSalvagers.xcodeproj in Xcode"
    echo "   2. Right-click 'Game/Managers' folder"
    echo "   3. Add Files... → Select SimpleVectorMapLoader.swift"
    echo "   4. Right-click 'SpaceSalvagers' main folder"
    echo "   5. Add Files... → Select vector_maps.txt"
    echo "   6. Make sure 'Add to target: SpaceSalvagers' is checked"
fi

echo "🔨 Ready to build!"