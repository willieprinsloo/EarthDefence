#!/usr/bin/env swift
import Foundation

// Test script to verify vector map loading
let vectorMapPath = "/Users/wlprinsloo/Documents/Projects/Tower-game/Maps/vector_maps.txt"

print("🎨 Testing Vector Map System")
print("==========================")

// Test if the file exists and read it
if FileManager.default.fileExists(atPath: vectorMapPath) {
    print("✅ Found vector_maps.txt")
    
    do {
        let content = try String(contentsOfFile: vectorMapPath, encoding: .utf8)
        print("📄 File size: \(content.count) characters")
        
        let lines = content.components(separatedBy: "\n")
        print("📋 Total lines: \(lines.count)")
        
        var mapCount = 0
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("MAP ") {
                mapCount += 1
                print("🗺️ Found map: \(trimmed)")
            }
        }
        print("📊 Total maps found: \(mapCount)")
        
    } catch {
        print("❌ Error reading file: \(error)")
    }
} else {
    print("❌ vector_maps.txt not found")
}