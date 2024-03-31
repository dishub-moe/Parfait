import XCTVapor
import FluentSQLiteDriver
@testable import Parfait


final class ParfaitTests: XCTestCase {
    
    func test100() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/100/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test101() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/101/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test102() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/102/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test103() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/103/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test104() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/104/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test200() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/200/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test201() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/201/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test202() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/202/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test203() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/203/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test204() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/204/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test205() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/205/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
    func test300() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/300/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }
    
}
