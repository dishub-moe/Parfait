protocol YouTubeDataAPI {
    
    var youTubeAPIKey: String { get }
    
    func fetchYouTubeVideos(ids: [String]) async throws -> YouTubePage<YouTubeVideo>
    
    func fetchYouTubeChannels(ids: [String]) async throws -> YouTubePage<YouTubeChannel>
    
}
