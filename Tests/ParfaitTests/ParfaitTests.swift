import XCTVapor
import FluentSQLiteDriver
import Queues
@testable import Parfait


final class ParfaitTests: XCTestCase {
    
    func testExecute() async throws {
        let youTubeChannelID = Environment.get("TEST_YOUTUBE_CHANNEL_ID")!
        let discordWebhookURL = Environment.get("TEST_DISCORD_WEBHOOK_URL")!
        let mentioningRoles = Environment.get("TEST_MENTIONING_DISCORD_ROLES")!
        let app = Application(.testing)
        defer { app.shutdown() }
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.logger.logLevel = .trace
        try configure(app)
        try await app.autoMigrate()
        if let subscribeCommand = app.asyncCommands.commands
            .first(where: { command in command.key == "subscribe"})?
            .value {
            let commandInput = CommandInput(arguments: [
                "app subscribe",
                youTubeChannelID,
                discordWebhookURL,
                "--mentioning-discord-roles",
                mentioningRoles
            ])
            var context = CommandContext(console: app.console, input: commandInput)
            context.application = app
            try await app.console.run(subscribeCommand, with: context)
        }
        var queueCommandContext = CommandContext(
            console: app.console,
            input: .init(arguments: ["app queue"])
        )
        queueCommandContext.application = app
        try await QueuesCommand(application: app).run(using: &queueCommandContext)
        try await app.execute()
    }
    
}
