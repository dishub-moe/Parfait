import DiscordWebhookExecutor
import Foundation
import Queues
import SubscriberVapor
import Vapor


struct ExecuteDiscordWebhookJob: AsyncJob {
    
    struct Payload: Codable {
        let youTubeChannel: YouTubeChannel
        let youTubeVideo: YouTubeVideo
        let discordWebhookURL: URL
        let mentioningDiscordRoles: [String]
    }
    
    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        try await DiscordWebhook(
            payload.discordWebhookURL,
            using: context.application.client
        ).execute(content: payload.createContent())
    }
    
}


extension ExecuteDiscordWebhookJob.Payload {
    
    fileprivate func createContent() throws -> WebhookContent {
        let roleSnowflakes = mentioningDiscordRoles.map({ "<@&\($0)>" }).joined(separator: " ")
        return try Content
            .builder(text: "\(roleSnowflakes) \(youTubeVideo.snippet.title) https://www.youtube.com/watch?v=\(youTubeVideo.id)")
            .profile(
                Profile(
                    username: youTubeChannel.snippet.title,
                    avatarURL: youTubeChannel.snippet
                        .thumbnails?.default?.url.convertToURL()
                )
            )
            .build()
    }
    
}


private class DiscordWebhook: Webhook {
    
    let url: URL
    
    private let client: Client
    
    init(_ url: URL, using client: Client) {
        self.url = url
        self.client = client
    }
    
    func execute(content: WebhookContent) async throws {
        let boundary = "boundary-Parfait-\(UUID().uuidString)"
        let response = try await client.post(
            URI(string: url.absoluteString),
            headers: [
                "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ]
        ) { req in
            try req.body = .init(data: content.multipartBody(using: boundary))
        }
        if !response.status.isSuccess {
            throw response.status
        }
    }
    
}


extension HTTPResponseStatus: LocalizedError {
    
    public var errorDescription: String? { reasonPhrase }
    
}


private typealias WebhookContent = DiscordWebhookExecutor.Content
