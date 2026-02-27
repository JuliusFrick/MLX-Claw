// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MLXClaw",
    platforms: [.iOS(.v15)],
    products: [
        .executable(name: "MLXClaw", targets: ["MLXClaw"])
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MLXClaw",
            dependencies: ["Starscream"],
            path: "Sources"
        )
    ]
)
