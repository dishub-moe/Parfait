// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Parfait",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Parfait",
            targets: ["Parfait"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/WebSubKit/SubscriberVapor.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.1"),
        .package(url: "https://github.com/naufalfachrian/FeedKit", from: "9.1.3"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.6.0"),
        .package(url: "https://github.com/dishub-moe/discord-webhook-executor.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Parfait",
            dependencies: [
                .product(name: "SubscriberVapor", package: "SubscriberVapor"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "FeedKit", package: "FeedKit"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
                .product(name: "DiscordWebhookExecutor", package: "discord-webhook-executor")
            ]
        ),
        .testTarget(
            name: "ParfaitTests",
            dependencies: [
                .target(name: "Parfait"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        )
    ]
)
