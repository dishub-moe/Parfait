import Foundation


enum YouTubeFeed {
    
    case youTubeVideos(_ youTubeVideos: [YouTubeVideoFeed])
    
    case deletedYouTubeVideos(_ videos: [DeletedYouTubeVideoFeed])
    
    case empty(_ raw: Data)
    
}


struct YouTubeVideoFeed: AnyYouTubeVideoFeed, Codable {
    
    public let videoID: String
    
    public let videoTitle: String
    
    public let channelID: String
    
    public let channelName: String
    
    public let publishedAt: Date
    
}


struct DeletedYouTubeVideoFeed: AnyYouTubeVideoFeed, Codable {
    
    public let videoID: String
    
}


protocol AnyYouTubeVideoFeed: Codable {
    
    var videoID: String { get }
    
}
