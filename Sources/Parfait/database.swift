import FluentKit
import FluentMySQLDriver
import Vapor


func databaseConfig() throws -> DatabaseConfigurationFactory {
    guard let username = Environment.get("DATABASE_USERNAME") else {
        throw ConfigurationError(description: "DATABASE_USERNAME environment variable is not set")
    }
    guard let password = Environment.get("DATABASE_PASSWORD") else {
        throw ConfigurationError(description: "DATABASE_PASSWORD environment variable is not set")
    }
    guard let database = Environment.get("DATABASE_NAME") else {
        throw ConfigurationError(description: "DATABASE_NAME environment variable is not set")
    }
    return .mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: username,
        password: password,
        database: database,
        tlsConfiguration: .makeClientConfiguration()
    )
}


func databaseID() -> DatabaseID {
    .mysql
}
