import FluentKit
import Foundation
import SubscriberKit
import Vapor


protocol DiscordWebhookRepository {
    
    func discordWebhookSubscriptions(for youTubeChannelIDs: [String]) async throws -> [DiscordWebhookSubscription]
    
    func discordWebhookSubscription(for youTubeChannelID: String, to webhook: URL) async throws -> DiscordWebhookSubscription?
    
    func createOrUpdateDiscordWebhookSubscription(
        youTubeChannelID: String,
        discordWebhookURL: URL,
        label: String?
    ) async throws -> DiscordWebhookSubscription
    
    func selectDiscordWebhookSubscriptions(
        youTubeChannelID: String?,
        discordWebhookURL: URL?,
        label: String?
    ) async throws -> [DiscordWebhookSubscription]
    
    func deleteDiscordWebhookSubscriptions(
        youTubeChannelID: String?,
        discordWebhookURL: URL?,
        label: String?
    ) async throws
    
    func storeMentioningDiscordRoles(_ roles: [(String, String?)], on discordWebhookSubscription: DiscordWebhookSubscription) async throws -> [MentioningDiscordRole]
    
}


extension Application: DiscordWebhookRepository {
    
    func discordWebhookSubscriptions(for youTubeChannelIDs: [String]) async throws -> [DiscordWebhookSubscription] {
        return try await DiscordWebhookSubscriptionRow.query(on: db)
            .with(\.$mentioningDiscordRoleChildren)
            .filter(\.$youTubeChannelID ~~ youTubeChannelIDs)
            .all()
    }
    
    func discordWebhookSubscription(for youTubeChannelID: String, to webhook: URL) async throws -> DiscordWebhookSubscription? {
        return try await DiscordWebhookSubscriptionRow.query(on: db)
            .filter(\.$youTubeChannelID, .equal, youTubeChannelID)
            .filter(\.$discordWebhookURL, .equal, webhook)
            .first()
    }
    
    func createOrUpdateDiscordWebhookSubscription(
        youTubeChannelID: String,
        discordWebhookURL: URL,
        label: String?
    ) async throws -> DiscordWebhookSubscription {
        if let existing = try await DiscordWebhookSubscriptionRow.query(on: db)
            .filter(\.$youTubeChannelID, .equal, youTubeChannelID)
            .filter(\.$discordWebhookURL, .equal, discordWebhookURL)
            .first() {
            existing.label = label
            try await existing.update(on: db)
            return existing
        }
        let created = DiscordWebhookSubscriptionRow(
            youTubeChannelID: youTubeChannelID,
            discordWebhookURL: discordWebhookURL,
            label: label
        )
        try await created.save(on: db)
        return created
    }
    
    func selectDiscordWebhookSubscriptions(
        youTubeChannelID: String?,
        discordWebhookURL: URL?,
        label: String?
    ) async throws -> [DiscordWebhookSubscription] {
        return try await selectDiscordWebhookSubscriptionRows(
            youTubeChannelID: youTubeChannelID,
            discordWebhookURL: discordWebhookURL,
            label: label
        )
    }
    
    func deleteDiscordWebhookSubscriptions(
        youTubeChannelID: String?,
        discordWebhookURL: URL?,
        label: String?
    ) async throws {
        try await selectDiscordWebhookSubscriptionRows(
            youTubeChannelID: youTubeChannelID,
            discordWebhookURL: discordWebhookURL,
            label: label
        ).delete(on: db)
    }
    
    func storeMentioningDiscordRoles(_ roles: [(String, String?)], on discordWebhookSubscription: any DiscordWebhookSubscription) async throws -> [any MentioningDiscordRole] {
        var stored: [MentioningDiscordRole] = []
        for role in roles {
            if try await mentioningDiscordRolesAlreadyExist(
                role.0,
                on: discordWebhookSubscription
            ) {
                continue
            }
            guard let storedItem = MentioningDiscordRoleRow(
                roleSnowflake: role.0,
                label: role.1,
                discordWebhookSubscription: discordWebhookSubscription
            ) else {
                continue
            }
            try await storedItem.save(on: db)
            stored.append(storedItem)
        }
        return stored
    }
    
    private func selectDiscordWebhookSubscriptionRows(
        youTubeChannelID: String?,
        discordWebhookURL: URL?,
        label: String?
    ) async throws -> [DiscordWebhookSubscriptionRow] {
        let selected = DiscordWebhookSubscriptionRow.query(on: db)
            .with(\.$mentioningDiscordRoleChildren)
        if let youTubeChannelID {
            selected.filter(\.$youTubeChannelID, .equal, youTubeChannelID)
        }
        if let discordWebhookURL {
            selected.filter(\.$discordWebhookURL, .equal, discordWebhookURL)
        }
        if let label {
            selected.filter(\.$label, .equal, label)
        }
        return try await selected.all()
    }
    
    private func mentioningDiscordRolesAlreadyExist(
        _ roleSnowflake: String,
        on discordWebhookSubscription: DiscordWebhookSubscription
    ) async throws -> Bool {
        return try await MentioningDiscordRoleRow.query(on: db)
            .filter(\.$roleSnowflake == roleSnowflake)
            .filter(\.$discordWebhookSubscriptionParent.$id == discordWebhookSubscription.requireID())
            .count() > 0
    }
    
}


extension DiscordWebhookSubscriptionRow {
    
    convenience init(youTubeChannelID: String, discordWebhookURL: URL, label: String?) {
        self.init()
        self.youTubeChannelID = youTubeChannelID
        self.discordWebhookURL = discordWebhookURL
        self.label = label
    }
    
}


extension MentioningDiscordRoleRow {
    
    convenience init?(roleSnowflake: String, label: String?, discordWebhookSubscription: DiscordWebhookSubscription) {
        guard
            let discordWebhookSubscriptionModel = discordWebhookSubscription as? DiscordWebhookSubscriptionRow,
            let subscriptionID = discordWebhookSubscriptionModel.id
        else {
            return nil
        }
        self.init()
        self.roleSnowflake = roleSnowflake
        self.label = label
        self.$discordWebhookSubscriptionParent.id = subscriptionID
    }
    
}
