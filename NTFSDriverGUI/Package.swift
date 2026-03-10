// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NTFSDriverGUI",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "NTFSDriverGUI",
            targets: ["NTFSDriverGUI"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NTFSDriverGUI",
            path: "NTFSDriverGUI"
        )
    ]
)
