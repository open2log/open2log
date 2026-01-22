// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Open2Log",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Open2Log",
            targets: ["Open2Log"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Open2Log",
            dependencies: [],
            path: "Open2Log/Sources"
        ),
        .testTarget(
            name: "Open2LogTests",
            dependencies: ["Open2Log"],
            path: "Open2Log/Tests"
        )
    ]
)
