#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'SpaceSalvagers.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the Scenes group
main_group = project.main_group
game_group = main_group['SpaceSalvagers']['Game']
scenes_group = game_group['Scenes']

unless scenes_group
  puts "❌ Could not find Scenes group"
  exit 1
end

# Check if MapSelectionScene.swift already exists in the project
map_selection_ref = scenes_group.files.find { |f| f.path == 'MapSelectionScene.swift' }

if map_selection_ref
  puts "⚠️ MapSelectionScene.swift already exists in project, removing and re-adding..."
  # Remove from build phases
  target.source_build_phase.files.each do |bf|
    if bf.file_ref && bf.file_ref.path == 'MapSelectionScene.swift'
      target.source_build_phase.remove_build_file(bf)
    end
  end
  # Remove from group
  scenes_group.children.delete(map_selection_ref)
end

# Add MapSelectionScene.swift to the project
file_path = 'SpaceSalvagers/Game/Scenes/MapSelectionScene.swift'
file_ref = scenes_group.new_reference(file_path)
file_ref.name = 'MapSelectionScene.swift'
file_ref.path = 'MapSelectionScene.swift'
target.add_file_references([file_ref])

puts "✅ Added MapSelectionScene.swift to project"

# Clean up duplicate build files
puts "🧹 Cleaning up duplicate build files..."

# Remove duplicate SimpleVectorMapLoader.swift from compile sources
build_files_to_remove = []
seen_files = {}

target.source_build_phase.files.each do |build_file|
  if build_file.file_ref
    file_path = build_file.file_ref.path
    if seen_files[file_path]
      build_files_to_remove << build_file
      puts "  Removing duplicate: #{file_path}"
    else
      seen_files[file_path] = true
    end
  end
end

build_files_to_remove.each do |bf|
  target.source_build_phase.remove_build_file(bf)
end

# Remove duplicate vector_maps.txt from resources
resource_files_to_remove = []
seen_resources = {}

target.resources_build_phase.files.each do |build_file|
  if build_file.file_ref
    file_path = build_file.file_ref.path
    if seen_resources[file_path]
      resource_files_to_remove << build_file
      puts "  Removing duplicate resource: #{file_path}"
    else
      seen_resources[file_path] = true
    end
  end
end

resource_files_to_remove.each do |bf|
  target.resources_build_phase.remove_build_file(bf)
end

# Save the project
project.save

puts "✅ Project updated successfully!"
puts "📱 Ready to build!"