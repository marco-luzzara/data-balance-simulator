// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataBalanceSimulator",
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.1")),
        .package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.0")),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .executableTarget(
            name: "DataBalanceSimulator",
            dependencies: [
                .product(name: "PythonKit", package: "PythonKit"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .testTarget(
            name: "DataBalanceSimulatorTests", 
            dependencies: [
                "DataBalanceSimulator"
            ]
        )
    ]
)
