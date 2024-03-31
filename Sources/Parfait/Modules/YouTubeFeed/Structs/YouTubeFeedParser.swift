import Foundation
import FeedKit


protocol YouTubeFeedParser { }


extension YouTubeFeedParser {
    
    func parseYouTubeFeed(from data: Data) -> Result<YouTubeFeed, YouTubeFeedConsumerError> {
        switch FeedParser(data: data).parse() {
        case .success(let feed):
            let entries = feed.atomFeed?.entries ?? []
            if !entries.isEmpty {
                let youTubeVideos = entries.flatMap {
                    guard let item = YouTubeVideoFeed(from: $0) else {
                        return [] as [YouTubeVideoFeed]
                    }
                    return [item]
                }
                if youTubeVideos.isEmpty {
                    return .success(.empty(data))
                }
                return .success(.youTubeVideos(youTubeVideos))
            }
            let deletedEntries = feed.atomFeed?.deletedEntries ?? []
            if !deletedEntries.isEmpty {
                let deletedYouTubeVideos = deletedEntries.flatMap {
                    guard let entryID = $0.attributes?.ref else {
                        return [] as [DeletedYouTubeVideoFeed]
                    }
                    return [DeletedYouTubeVideoFeed(
                        videoID: entryID.dropPrefix("yt:video:")
                    )]
                }
                if deletedEntries.isEmpty {
                    return .success(.empty(data))
                }
                return .success(.deletedYouTubeVideos(deletedYouTubeVideos))
            }
            return .success(.empty(data))
        case .failure(let failure):
            return .failure(.failedParsing(data: data, reason: failure))
        }
    }
    
}


enum YouTubeFeedConsumerError: Error {
    
    case failedParsing(data: Data, reason: Error)
    
}


extension YouTubeVideoFeed {
    
    init?(from entry: AtomFeedEntry) {
        guard let yt = entry.yt else {
            return nil
        }
        guard let channelID = yt.channelID else {
            return nil
        }
        guard let channelName = entry.authors?.last?.name else {
            return nil
        }
        guard let videoID = yt.videoID else {
            return nil
        }
        guard let videoTitle = entry.title else {
            return nil
        }
        guard let publishedAt = entry.published else {
            return nil
        }
        self.init(
            videoID: videoID,
            videoTitle: videoTitle,
            channelID: channelID,
            channelName: channelName,
            publishedAt: publishedAt
        )
    }
    
}


extension String {
    
    fileprivate func dropPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
}
