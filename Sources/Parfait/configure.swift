import NIOSSL
import Fluent
import SubscriberFluent
import SubscriberVapor
import Vapor


func configure(
    _ app: Application
) throws {
    runSubscriberFluentMigration(on: app.migrations)
    
    app.asyncCommands.use(
        Subscribe(
            callbackURLGenerator: app,
            delegate: app
        ),
        as: "subscribe"
    )
    app.asyncCommands.use(
        Unsubscribe(delegate: app),
        as: "unsubscribe"
    )
    
    try app.register(
        collection: CallbackRoutes(
            callbackURLGenerator: app,
            delegate: app
        )
    )
}
