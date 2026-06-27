import FluentKit
import Foundation
import Queues
import Vapor


struct ExtractReceivedContentJob: AsyncJob, YouTubeFeedParser {

    struct Payload: Codable {
        let data: Data
    }

    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        context.logger.trace("Parsing YouTube feed data")
        switch parseYouTubeFeed(from: payload.data) {
        case .success(let content):
            context.logger.trace("Successfully parsing YouTube feed data")
            try await handle(content, using: context)
        case .failure(let reason):
            context.logger.trace("Failure when parsing YouTube feed data")
            try await handle(reason, using: context)
        }
    }

    private func handle(
        _ content: YouTubeFeed,
        using context: QueueContext
    ) async throws {
        switch content {
        case .youTubeVideos(let youTubeVideos):
            context.logger.trace("Found YouTube videos feed")
            context.logger.debug("Found YouTube videos feed", metadata: [
                "count": "\(youTubeVideos.count)",
                "videoIDs": "\(youTubeVideos.map({ $0.videoID }).joined(separator: ","))",
                "channelIDs": "\(youTubeVideos.map({ $0.channelID }).joined(separator: ","))"
            ])
            try await received(youTubeVideos, on: context)
        case .deletedYouTubeVideos(let deletedYouTubeVideos):
            context.logger.trace("Found deleted YouTube videos feed")
            context.logger.debug("Found deleted YouTube videos feed", metadata: [
                "count": "\(deletedYouTubeVideos.count)",
                "videoIDs": "\(deletedYouTubeVideos.map({ $0.videoID }).joined(separator: ","))"
            ])
            try await received(deleted: deletedYouTubeVideos, on: context)
        case .empty:
            context.logger.info("Found empty feed when extracting received content job")
        }
    }

    private func handle(
        _ failure: YouTubeFeedConsumerError,
        using context: QueueContext
    ) async throws {
        switch failure {
        case .failedParsing(let data, let reason):
            context.logger.error(
                "Failed parsing when extract received content job",
                metadata: [
                    "data": "\(String(data: data, encoding: .utf8) ?? "Can't read data as UTF-8")",
                    "reason": "\(reason.localizedDescription)"
                ]
            )
        }
    }

    // MARK: - Received videos

    private func received(
        _ feeds: [YouTubeVideoFeed],
        on context: QueueContext
    ) async throws {
        let channelIDs = feeds.map { $0.channelID }
        let videoIDs = feeds.map { $0.videoID }

        let youTubeChannels = try await fetchChannels(ids: channelIDs, context: context)
        let youTubeVideos = try await fetchVideos(ids: videoIDs, context: context)
        let subscriptions = try await fetchSubscriptions(for: channelIDs, context: context)

        try await dispatchNotifications(
            subscriptions: subscriptions,
            channels: youTubeChannels,
            videos: youTubeVideos,
            context: context
        )
    }

    private func fetchChannels(
        ids channelIDs: [String],
        context: QueueContext
    ) async throws -> [YouTubeChannel] {
        var result: [YouTubeChannel] = []
        for chunk in channelIDs.chunks(ofCount: 50) {
            let ids = Array(chunk)
            context.logger.trace("Fetching YouTube channels' detail")
            context.logger.debug("Fetching YouTube channels' detail", metadata: [
                "count": "\(ids.count)",
                "channelIDs": "\(ids.joined(separator: ","))"
            ])
            let fetched = try await context.application.fetchYouTubeChannels(ids: ids).items
            context.logger.trace("YouTube channels' detail fetched")
            context.logger.debug("YouTube channels' detail fetched", metadata: [
                "count": "\(fetched.count)",
                "channelIDs": "\(fetched.map({ $0.id }).joined(separator: ","))"
            ])
            result.append(contentsOf: fetched)
        }
        return result
    }

    private func fetchVideos(
        ids videoIDs: [String],
        context: QueueContext
    ) async throws -> [YouTubeVideo] {
        var result: [YouTubeVideo] = []
        for chunk in videoIDs.chunks(ofCount: 50) {
            let ids = Array(chunk)
            context.logger.trace("Fetching YouTube videos' detail")
            context.logger.debug("Fetching YouTube videos' detail", metadata: [
                "count": "\(ids.count)",
                "videoIDs": "\(ids.joined(separator: ","))"
            ])
            let fetched = try await context.application.fetchYouTubeVideos(ids: ids).items
            context.logger.trace("YouTube videos' detail fetched")
            context.logger.debug("YouTube videos' detail fetched", metadata: [
                "count": "\(fetched.count)",
                "videoIDs": "\(fetched.map({ $0.id }).joined(separator: ","))"
            ])
            result.append(contentsOf: fetched)
        }
        return result
    }

    private func fetchSubscriptions(
        for channelIDs: [String],
        context: QueueContext
    ) async throws -> [any DiscordWebhookSubscription] {
        context.logger.trace("Looking for Parfait subscriptions' related to the YouTube Channel")
        let subscriptions = try await context.application.discordWebhookSubscriptions(for: channelIDs)
        context.logger.trace("Parfait subscriptions' related to the YouTube Channel found")
        context.logger.debug(
            "Parfait subscriptions' related to the YouTube Channel found",
            metadata: [
                "count": "\(subscriptions.count)",
                "subscriptionIDs": "\(subscriptions.map({ $0.id?.uuidString ?? "/" }).joined(separator: ","))"
            ]
        )
        return subscriptions
    }

    private func dispatchNotifications(
        subscriptions: [any DiscordWebhookSubscription],
        channels: [YouTubeChannel],
        videos: [YouTubeVideo],
        context: QueueContext
    ) async throws {
        for subscription in subscriptions {
            guard let youTubeChannel = channels.first(where: { $0.id == subscription.youTubeChannelID }) else {
                context.logger.warning(
                    "Skipping subscription: YouTube channel not found in API response",
                    metadata: ["youTubeChannelID": "\(subscription.youTubeChannelID)"]
                )
                continue
            }
            let channelVideos = videos.filter({ $0.snippet.channelID == youTubeChannel.id })
            if channelVideos.isEmpty {
                context.logger.warning(
                    "Skipping subscription: no videos fetched for channel",
                    metadata: ["youTubeChannelID": "\(youTubeChannel.id)"]
                )
                continue
            }
            try await youTubeChannel.save(on: context.application.db)
            for youTubeVideo in channelVideos {
                let shouldDispatch = try await shouldExecuteDiscordWebhookJob(
                    video: youTubeVideo,
                    on: context
                )
                try await youTubeVideo.save(on: context.application.db)
                if shouldDispatch {
                    try await context.queue.dispatch(
                        ExecuteDiscordWebhookJob.self,
                        .init(
                            youTubeChannel: youTubeChannel,
                            youTubeVideo: youTubeVideo,
                            discordWebhookURL: subscription.discordWebhookURL,
                            mentioningDiscordRoles: subscription.mentioningDiscordRoles.map { $0.roleSnowflake }
                        )
                    )
                }
            }
        }
    }

    private func shouldExecuteDiscordWebhookJob(video: YouTubeVideo, on context: QueueContext) async throws -> Bool {
        if Environment.get("ONLY_NOTIFY_ONCE") != nil {
            return try await YouTubeVideoRow.query(on: context.application.db)
                .filter(\.$videoID == video.id)
                .count() == 0
        }
        return true
    }

    // MARK: - Deleted videos

    private func received(
        deleted feeds: [DeletedYouTubeVideoFeed],
        on context: QueueContext
    ) async throws {
        context.logger.info(
            "Found deleted YouTube Video when extracting received content",
            metadata: [
                "videoIDs": "\(feeds.map({ $0.videoID }).joined(separator: ","))",
            ]
        )
        for feed in feeds {
            try await feed.delete(on: context.application.db)
        }
    }

}


extension DeletedYouTubeVideoFeed {

    func delete(on db: Database) async throws {
        try await YouTubeVideoRow.query(on: db)
            .filter(\.$videoID == self.videoID)
            .delete()
    }

}
