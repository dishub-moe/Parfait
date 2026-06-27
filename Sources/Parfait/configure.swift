import NIOSSL
import Fluent
import QueuesRedisDriver
import SubscriberFluent
import SubscriberVapor
import Vapor


func configure(
    _ app: Application
) throws {
    guard Environment.get("BASE_URL") != nil else {
        throw ConfigurationError(description: "BASE_URL environment variable is not set")
    }
    guard Environment.get("CALLBACK_PATH") != nil else {
        throw ConfigurationError(description: "CALLBACK_PATH environment variable is not set")
    }
    guard let youTubeAPIKey = Environment.get("YOUTUBE_API_KEY") else {
        throw ConfigurationError(description: "YOUTUBE_API_KEY environment variable is not set")
    }
    guard let redisURL = Environment.get("REDIS_URL") else {
        throw ConfigurationError(description: "REDIS_URL environment variable is not set")
    }

    app.youTubeDataAPIService = YouTubeDataAPIService(apiKey: youTubeAPIKey)

    runSubscriberFluentMigration(on: app.migrations)
    app.migrations.add(CreateDiscordWebhookSubscriptionsTable())
    app.migrations.add(CreateMentioningDiscordRolesTable())
    app.migrations.add(CreateYouTubeChannelsTable())
    app.migrations.add(CreateYouTubeVideosTable())

    app.asyncCommands.use(Subscribe(), as: "subscribe")
    app.asyncCommands.use(Unsubscribe(), as: "unsubscribe")
    app.asyncCommands.use(
        Resubscribe(
            callbackURLGenerator: app,
            delegate: app
        ),
        as: "resubscribe"
    )

    app.queues.add(ExecuteDiscordWebhookJob())
    app.queues.add(ExtractReceivedContentJob())

    try app.register(
        collection: CallbackRoutes(
            callbackURLGenerator: app,
            delegate: app
        )
    )

    try app.queues.use(.redis(url: redisURL))
}
