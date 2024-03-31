// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SubscriberVaporStarter",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SubscriberVaporStarter",
            targets: ["SubscriberVaporStarter"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/WebSubKit/SubscriberVapor.git", revision: "1405912"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0")
    ],
    targets: [
        .executableTarget(
            name: "SubscriberVaporStarter",
            dependencies: [
                .product(name: "SubscriberVapor", package: "SubscriberVapor")
            ]
        ),
        .testTarget(
            name: "SubscriberVaporStarterTests",
            dependencies: [
                .target(name: "SubscriberVaporStarter"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        )
    ]
)
