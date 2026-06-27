import XCTVapor
import FluentSQLiteDriver
import Queues
@testable import Parfait


final class SubscriberVaporTests: XCTestCase {

    private func makeApp() async throws -> Application {
        let app = try await Application.make(.testing)
        addTeardownBlock { try await app.asyncShutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        try configure(app)
        try await app.autoMigrate()
        try await app.startup()
        return app
    }

    private func subscribe(_ app: Application, path: String) async throws {
        try await app.subscribe(
            topic: URL(string: "https://websub.rocks/blog/\(path)/DvnBzwGWg17e2zheq4iI")!,
            to: try app.generateNewCallbackURL(),
            leaseSeconds: 3600,
            preferredHub: nil,
            on: app,
            delegate: app
        )
    }

    func test100() async throws { try await subscribe(makeApp(), path: "100") }
    func test101() async throws { try await subscribe(makeApp(), path: "101") }
    func test102() async throws { try await subscribe(makeApp(), path: "102") }
    func test103() async throws { try await subscribe(makeApp(), path: "103") }
    func test104() async throws { try await subscribe(makeApp(), path: "104") }
    func test200() async throws { try await subscribe(makeApp(), path: "200") }
    func test201() async throws { try await subscribe(makeApp(), path: "201") }
    func test202() async throws { try await subscribe(makeApp(), path: "202") }
    func test203() async throws { try await subscribe(makeApp(), path: "203") }
    func test204() async throws { try await subscribe(makeApp(), path: "204") }
    func test205() async throws { try await subscribe(makeApp(), path: "205") }
    func test300() async throws { try await subscribe(makeApp(), path: "300") }

}
