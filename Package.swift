// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SpaceSalvagers",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "SpaceSalvagers",
            dependencies: ["AudioKit"]
        )
    ]
)