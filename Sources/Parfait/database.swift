import FluentKit
import FluentMySQLDriver
import Vapor


func databaseConfig() -> DatabaseConfigurationFactory {
    .mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "parfait_db_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "parfait_db_password",
        database: Environment.get("DATABASE_NAME") ?? "parfait_db_database",
        tlsConfiguration: Environment.get("DATABASE_SKIP_CERTIFICATE_VERIFICATION") == nil ? .standard() : .noCertificateVerification()
    )
}


func databaseID() -> DatabaseID {
    .mysql
}


extension TLSConfiguration {
    
    static func standard() -> TLSConfiguration {
        return .makeClientConfiguration()
    }
    
    static func noCertificateVerification() -> TLSConfiguration {
        var tlsConfiguration: TLSConfiguration = .makeClientConfiguration()
        tlsConfiguration.certificateVerification = .none
        return tlsConfiguration
    }
    
}
