import SubscriberKit
import SubscriberVapor
import Vapor


struct Subscribe: AsyncCommand {
    
    struct Signature: CommandSignature {
        
        @Argument(
            name: "youtube-channel-id",
            help: "YouTube Channel ID to subscribe"
        )
        var youTubeChannelID: String
        
        @Argument(
            name: "discord-webhook-url",
            help: "Discord Webhook URL to connect"
        )
        var discordWebhook: String
        
        @Option(
            name: "mentioning-discord-roles",
            help: "Discord server roles to mention, separated with comma (,)"
        )
        var mentioningDiscordRoles: String?
        
        @Option(
            name: "label",
            help: "Label the subscription"
        )
        var label: String?
        
    }
    
    let help: String = "Subscribe to YouTube channel push notification and deliver it's to a Discord Webhook"
    
    func run(using context: CommandContext, signature: Signature) async throws {
        let youTubeChannelID = signature.youTubeChannelID
        let discordWebhook = signature.discordWebhook
        try await activateYouTubeChannelSubscription(
            youTubeChannelID,
            using: context
        )
        let subscription = try await context.application
            .createOrUpdateDiscordWebhookSubscription(
                youTubeChannelID: youTubeChannelID,
                discordWebhookURL: discordWebhook.convertToURL(),
                label: signature.label
            )
        context.application.logger.trace("Subscription updated")
        context.application.logger.debug("Subscription updated", metadata: [
            "YouTube Channel ID":
                "\(subscription.youTubeChannelID)",
            "Discord Webhook URL":
                "\(subscription.discordWebhookURL)",
            "Label":
                "\(String(describing: subscription.label))",
            "Discord Webhook Subscription ID":
                "\(String(describing: subscription.id))"
        ])
        if let mentioningDiscordRoles = signature.mentioningDiscordRoles?
            .split(separator: ",")
            .map({ String($0) }) {
            try await connect(mentioningDiscordRoles, to: subscription, using: context)
        }
    }
    
}


extension Subscribe {
    
    fileprivate func activateYouTubeChannelSubscription(
        _ youTubeChannelID: String,
        using context: CommandContext
    ) async throws {
        let topic = try "https://www.youtube.com/xml/feeds/videos.xml?channel_id=\(youTubeChannelID)"
            .convertToURL()
        let subscription = try await context.application.subscriptions(for: topic).first
        if let subscription {
            // Resubscribe existing subscription
            try await context.application.resubscribe(
                callback: subscription.callback,
                leaseSeconds: nil,
                on: context.application,
                delegate: context.application
            )
        } else {
            // Subscribe a new subscription
            try await context.application.subscribe(
                topic: topic,
                to: context.application.generateNewCallbackURL(),
                leaseSeconds: nil,
                preferredHub: "https://pubsubhubbub.appspot.com".convertToURL(),
                on: context.application,
                delegate: context.application
            )
        }
    }
    
    fileprivate func connect(
        _ mentioningDiscordRoles: [String],
        to subscription: DiscordWebhookSubscription,
        using context: CommandContext
    ) async throws {
        let stored = try await context.application.storeMentioningDiscordRoles(
            mentioningDiscordRoles.map({ ($0, nil as String?) }),
            on: subscription
        )
        context.application.logger.trace("\(stored.count) Discord role mentions stored")
        context.application.logger.debug("\(stored.count) Discord role mentions stored", metadata: [
            "Discord Roles to Mention":
                "\(stored.map({ $0.roleSnowflake }).joined(separator: ","))",
            "YouTube Channel ID":
                "\(subscription.youTubeChannelID)",
            "Discord Webhook URL":
                "\(subscription.discordWebhookURL)",
            "Label":
                "\(String(describing: subscription.label))",
            "Discord Webhook Subscription ID":
                "\(String(describing: subscription.id))"
        ])
    }
    
}
