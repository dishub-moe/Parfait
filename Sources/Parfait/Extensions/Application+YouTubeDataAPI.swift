import Vapor


struct YouTubeDataAPIService {
    let apiKey: String
}

extension Application {

    private struct YouTubeDataAPIServiceKey: StorageKey {
        typealias Value = YouTubeDataAPIService
    }

    var youTubeDataAPIService: YouTubeDataAPIService {
        get {
            guard let service = storage[YouTubeDataAPIServiceKey.self] else {
                fatalError("YouTubeDataAPIService not configured — call app.configureYouTubeDataAPI() at startup")
            }
            return service
        }
        set {
            storage[YouTubeDataAPIServiceKey.self] = newValue
        }
    }

}

extension Application: YouTubeDataAPI {

    var youTubeAPIKey: String { youTubeDataAPIService.apiKey }

    func fetchYouTubeVideos(ids: [String]) async throws -> YouTubePage<YouTubeVideo> {
        var headers = HTTPHeaders()
        headers.add(name: .accept, value: "application/json")
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
        headers.add(name: .accept, value: "application/json")
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
