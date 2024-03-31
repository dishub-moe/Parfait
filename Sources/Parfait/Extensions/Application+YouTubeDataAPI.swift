import Vapor


extension Application: YouTubeDataAPI {
    
    fileprivate static let YOUTUBE_API_KEY = "YOUTUBE_API_KEY"
    
    var youTubeAPIKey: String {
        guard let youTubeAPIKey = Environment.get(Self.YOUTUBE_API_KEY) else {
            fatalError("\(Self.YOUTUBE_API_KEY) is not defined")
        }
        return youTubeAPIKey
    }
    
    func fetchYouTubeVideos(ids: [String]) async throws -> YouTubePage<YouTubeVideo> {
        var headers = HTTPHeaders()
        headers.add(name: HTTPHeaders.Name.accept, value: "application/json")
        let response = try await client.get(
            URI(string: "https://youtube.googleapis.com/youtube/v3/videos"),
            headers: headers
        ) { request in
            try request.query.encode(FetchYouTubeVideoByIDsQuery(
                part: [
                    "id",
                    "snippet",
                    "contentDetails",
                    "status",
                    "statistics",
                    "liveStreamingDetails",
                ],
                id: ids,
                key: youTubeAPIKey
            ), using: URLEncodedFormEncoder(configuration: .init(arrayEncoding: .values)))
        }
        return try response.content.decode(YouTubePage<YouTubeVideo>.self)
    }
    
    func fetchYouTubeChannels(ids: [String]) async throws -> YouTubePage<YouTubeChannel> {
        var headers = HTTPHeaders()
        headers.add(name: HTTPHeaders.Name.accept, value: "application/json")
        let response = try await client.get(
            URI(string: "https://youtube.googleapis.com/youtube/v3/channels"),
            headers: headers
        ) { request in
            try request.query.encode(FetchYouTubeChannelByIDsQuery(
                part: [
                    "id",
                    "snippet",
                    "contentDetails",
                    "status",
                    "statistics",
                ],
                id: ids,
                key: youTubeAPIKey
            ), using: URLEncodedFormEncoder(configuration: .init(arrayEncoding: .values)))
        }
        return try response.content.decode(YouTubePage<YouTubeChannel>.self)
    }
    
}


private struct FetchYouTubeVideoByIDsQuery: Codable {
    
    let part: [String]
    
    let id: [String]
    
    let key: String
    
}

private struct FetchYouTubeChannelByIDsQuery: Codable {
    
    let part: [String]
    
    let id: [String]
    
    let key: String
    
}
