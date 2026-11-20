// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MotoCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MotoCore", targets: ["MotoCore"]),
    ],
    targets: [
        .target(name: "MotoCore"),
        .testTarget(name: "MotoCoreTests", dependencies: ["MotoCore"]),
    ]
)
