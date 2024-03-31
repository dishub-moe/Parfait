import FluentKit
import Foundation


protocol DiscordWebhookSubscription {
    
    var id: UUID? { get }
    
    var youTubeChannelID: String { get }
    
    var discordWebhookURL: URL { get }
    
    var label: String? { get }
    
    var mentioningDiscordRoles: [MentioningDiscordRole] { get }
    
    func requireID() throws -> UUID
    
}


final class DiscordWebhookSubscriptionRow: Model {
    
    static let schema = "discord_webhook_subscriptions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "youtube_channel_id")
    var youTubeChannelID: String
    
    @Field(key: "discord_webhook_url")
    var discordWebhookURL: URL
    
    @Field(key: "label")
    var label: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$discordWebhookSubscriptionParent)
    var mentioningDiscordRoleChildren: [MentioningDiscordRoleRow]
    
}


extension DiscordWebhookSubscriptionRow: DiscordWebhookSubscription {
    
    var mentioningDiscordRoles: [MentioningDiscordRole] {
        $mentioningDiscordRoleChildren.wrappedValue
    }
    
}


struct CreateDiscordWebhookSubscriptionsTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(DiscordWebhookSubscriptionRow.schema)
            .id()
            .field("youtube_channel_id", .string, .required)
            .field("discord_webhook_url", .string, .required)
            .field("label", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "youtube_channel_id", "discord_webhook_url")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(DiscordWebhookSubscriptionRow.schema).delete()
    }
    
}
