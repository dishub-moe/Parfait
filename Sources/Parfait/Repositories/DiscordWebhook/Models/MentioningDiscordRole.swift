import FluentKit
import Foundation


protocol MentioningDiscordRole {
    
    var id: UUID? { get }
    
    var roleSnowflake: String { get }
    
    var label: String? { get }
    
    var discordWebhookSubscription: DiscordWebhookSubscription { get }
    
}


final class MentioningDiscordRoleRow: Model {
    
    static var schema = "mentioning_discord_roles"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "discord_webhook_subscription_id")
    var discordWebhookSubscriptionParent: DiscordWebhookSubscriptionRow
    
    @Field(key: "role_snowflake")
    var roleSnowflake: String
    
    @Field(key: "label")
    var label: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
}


extension MentioningDiscordRoleRow: MentioningDiscordRole {
    
    var discordWebhookSubscription: DiscordWebhookSubscription {
        $discordWebhookSubscriptionParent.wrappedValue
    }
    
}


struct CreateMentioningDiscordRolesTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(MentioningDiscordRoleRow.schema)
            .id()
            .field(
                "discord_webhook_subscription_id",
                .uuid,
                .required,
                .references(DiscordWebhookSubscriptionRow.schema, "id", onDelete: .cascade)
            )
            .field("role_snowflake", .string, .required)
            .field("label", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "discord_webhook_subscription_id", "role_snowflake")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(MentioningDiscordRoleRow.schema).delete()
    }
    
}
