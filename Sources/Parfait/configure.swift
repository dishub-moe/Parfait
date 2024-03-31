import NIOSSL
import Fluent
import QueuesRedisDriver
import SubscriberFluent
import SubscriberVapor
import Vapor


func configure(
    _ app: Application
) throws {
    guard let _ = Environment.get("BASE_URL") else {
        app.logger.critical(
            """
            Application URL is not defined.
            Please set the BASE_URL environment variable to the desired URL.
            """
        )
        fatalError()
    }
    guard let _ = Environment.get("CALLBACK_PATH") else {
        app.logger.critical(
            """
            Callback path is not defined.
            Please set the CALLBACK_PATH environment variable to the desired path.
            """
        )
        fatalError()
    }
    guard let _ = Environment.get("YOUTUBE_API_KEY") else {
        app.logger.critical(
            """
            YouTube API key is not defined.
            Please set the YOUTUBE_API_KEY environment variable to your YouTube API key.
            """
        )
        fatalError()
    }
    guard let _ = Environment.get("REDIS_URL") else {
        app.logger.critical(
            """
            Redis URL is not defined.
            Please set the REDIS_URL environment variable to the desired URL.
            """
        )
        fatalError()
    }
    
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
    
    try app.queues.use(.redis(url: Environment.get("REDIS_URL")!))
}
