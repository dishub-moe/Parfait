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
            break
        }
    }
    
    private func received(
        _ feeds: [YouTubeVideoFeed],
        on context: QueueContext
    ) async throws {
        let channelIDs = feeds.map { $0.channelID }
        let videoIDs = feeds.map { $0.videoID }
        
        // Fetch YouTube Channel Detail
        var youTubeChannels: [YouTubeChannel] = []
        for channelIDChunk in channelIDs.chunks(ofCount: 50) {
            let channelIDsArray = Array(channelIDChunk)
            context.logger.trace("Fetching YouTube channels' detail")
            context.logger.debug("Fetching YouTube channels' detail", metadata: [
                "count": "\(channelIDsArray.count)",
                "channelIDs": "\(channelIDsArray.joined(separator: ","))"
            ])
            let fetchedYouTubeChannels = try await context.application
                .fetchYouTubeChannels(ids: channelIDsArray)
                .items
            context.logger.trace("YouTube channels' detail fetched")
            context.logger.debug("YouTube channels' detail fetched", metadata: [
                "count": "\(fetchedYouTubeChannels.count)",
                "channelIDs": "\(fetchedYouTubeChannels.map({ $0.id }).joined(separator: ","))"
            ])
            youTubeChannels.append(
                contentsOf: fetchedYouTubeChannels
            )
        }
        
        // Fetch YouTube Video Detail
        var youTubeVideos: [YouTubeVideo] = []
        for videoIDChunk in videoIDs.chunks(ofCount: 50) {
            let videoIDsArray = Array(videoIDChunk)
            context.logger.trace("Fetching YouTube videos' detail")
            context.logger.debug("Fetching YouTube videos' detail", metadata: [
                "count": "\(videoIDsArray.count)",
                "videoIDs": "\(videoIDsArray.joined(separator: ","))"
            ])
            let fetchedYouTubeVideos = try await context.application
                .fetchYouTubeVideos(ids: videoIDsArray)
                .items
            context.logger.trace("YouTube videos' detail fetched")
            context.logger.debug("YouTube videos' detail fetched", metadata: [
                "count": "\(fetchedYouTubeVideos.count)",
                "videoIDs": "\(fetchedYouTubeVideos.map({ $0.id }).joined(separator: ","))"
            ])
            youTubeVideos.append(
                contentsOf: fetchedYouTubeVideos
            )
        }
        
        // Find the subscriptions related to the YouTube Channels
        // from the repository
        context.logger.trace("Looking for Parfait subscriptions' related to the YouTube Channel")
        let subscriptions = try await context.application
            .discordWebhookSubscriptions(for: channelIDs)
        context.logger.trace("Parfait subscriptions' related to the YouTube Channel found")
        context.logger.debug(
            "Parfait subscriptions' related to the YouTube Channel found",
            metadata: [
                "count": "\(subscriptions.count)",
                "subscriptionIDs": "\(subscriptions.map({ $0.id?.uuidString ?? "/" }).joined(separator: ","))"
            ]
        )
        
        // Iterate subscriptions and execute the Discord Webhook
        // for each related YouTube Videos to the subscription
        for subscription in subscriptions {
            guard let youTubeChannel = youTubeChannels
                .first(where: { $0.id == subscription.youTubeChannelID })
            else {
                continue
            }
            let youTubeVideosPerChannel = youTubeVideos
                .filter({ $0.snippet.channelID == youTubeChannel.id })
            if youTubeVideosPerChannel.isEmpty {
                continue
            }
            try await youTubeChannel.save(on: context.application.db)
            for youTubeVideo in youTubeVideos {
                let shouldExecuteDiscordWebhookJob = try await shouldExecuteDiscordWebhookJob(
                    video: youTubeVideo,
                    on: context
                )
                try await youTubeVideo.save(on: context.application.db)
                if shouldExecuteDiscordWebhookJob {
                    // Execute Discord Webhook via Job
                    try await context.queue.dispatch(
                        ExecuteDiscordWebhookJob.self,
                        .init(
                            youTubeChannel: youTubeChannel,
                            youTubeVideo: youTubeVideo,
                            discordWebhookURL: subscription.discordWebhookURL,
                            mentioningDiscordRoles: subscription.mentioningDiscordRoles
                                .map { $0.roleSnowflake }
                        )
                    )
                }
            }
        }
    }
    
    private func shouldExecuteDiscordWebhookJob(video: YouTubeVideo, on context: QueueContext) async throws -> Bool {
        if (Environment.get("ONLY_NOTIFY_ONCE") != nil) {
            return try await YouTubeVideoRow.query(on: context.application.db)
                .filter(\.$videoID == video.id)
                .count() == 0
        }
        return true
    }
    
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
