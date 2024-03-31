import SubscriberKit
import SubscriberVapor
import Vapor


struct Unsubscribe: AsyncCommand {
    
    struct Signature: CommandSignature {
        
        @Option(
            name: "youtube-channel-id",
            help: "YouTube channel ID to unsubscribe"
        )
        var youTubeChannelID: String?
        
        @Option(
            name: "discord-webhook-url",
            help: "Discord Webhook URL to unsubscribe"
        )
        var discordWebhook: String?
        
        @Option(
            name: "label",
            help: "Subscription label to unsubscribe"
        )
        var label: String?
        
        @Flag(name: "yes")
        var confirmed: Bool
        
    }
    
    var help: String = "Unsubscribe to a YouTube channel push notification, a Discord webhook, or both"
    
    func run(using context: CommandContext, signature: Signature) async throws {
        if signature.confirmed {
            try await unsubscribeSubscriptions(using: context, signature: signature)
        } else {
            let subscriptions = try await context.application.selectDiscordWebhookSubscriptions(
                youTubeChannelID: signature.youTubeChannelID,
                discordWebhookURL: signature.discordWebhook?.convertToURL(),
                label: signature.label
            )
            context.console.output("Subscriptions match", style: .warning, newLine: true)
            for subscription in subscriptions {
                context.console.output(
                    "Subscription ID    : \(subscription.id!)",
                    style: .warning,
                    newLine: true
                )
                context.console.output(
                    "YouTube Channel ID : \(subscription.youTubeChannelID)",
                    style: .warning,
                    newLine: true
                )
                context.console.output(
                    "Discord Webhook URL: \(subscription.discordWebhookURL)",
                    style: .warning,
                    newLine: true
                )
                context.console.output(
                    "Label              : \(subscription.label ?? "")",
                    style: .warning,
                    newLine: true
                )
                context.console.output("", newLine: true)
            }
            if context.console.confirm("Are you sure want to delete the subscriptions listed above?") {
                try await unsubscribeSubscriptions(using: context, signature: signature)
            }
        }
    }
    
    private func unsubscribeSubscriptions(
        using context: CommandContext,
        signature: Signature
    ) async throws {
        try await context.application.deleteDiscordWebhookSubscriptions(
            youTubeChannelID: signature.youTubeChannelID,
            discordWebhookURL: signature.discordWebhook?.convertToURL(),
            label: signature.label
        )
    }
    
}
