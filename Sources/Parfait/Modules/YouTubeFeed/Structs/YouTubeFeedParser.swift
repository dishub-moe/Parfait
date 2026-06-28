import Foundation
import FeedKit
#if canImport(FoundationXML)
import FoundationXML
#endif


protocol YouTubeFeedParser { }


extension YouTubeFeedParser {
    
    func parseYouTubeFeed(from data: Data) -> Result<YouTubeFeed, YouTubeFeedConsumerError> {
        let feed: AtomFeed
        do {
            feed = try AtomFeed(data: data)
        } catch {
            // v10 has no tombstone support; a deleted-only feed normally still parses,
            // but if FeedKit rejects it, try tombstone extraction before reporting failure.
            let deleted = parseDeletedEntries(from: data)
            if !deleted.isEmpty { return .success(.deletedYouTubeVideos(deleted)) }
            return .failure(.failedParsing(data: data, reason: error))
        }
        let youTubeVideos = (feed.entries ?? []).compactMap { YouTubeVideoFeed(from: $0) }
        if !youTubeVideos.isEmpty { return .success(.youTubeVideos(youTubeVideos)) }
        let deletedYouTubeVideos = parseDeletedEntries(from: data)
        if !deletedYouTubeVideos.isEmpty { return .success(.deletedYouTubeVideos(deletedYouTubeVideos)) }
        return .success(.empty(data))
    }
    
}


enum YouTubeFeedConsumerError: Error {
    
    case failedParsing(data: Data, reason: Error)
    
}


extension YouTubeVideoFeed {
    
    init?(from entry: AtomFeedEntry) {
        guard let yt = entry.youTube else {
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


extension YouTubeFeedParser {
    func parseDeletedEntries(from data: Data) -> [DeletedYouTubeVideoFeed] {
        let delegate = DeletedEntryParserDelegate()
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.delegate = delegate
        _ = parser.parse()
        return delegate.refs.map { DeletedYouTubeVideoFeed(videoID: $0.dropPrefix("yt:video:")) }
    }
}

private final class DeletedEntryParserDelegate: NSObject, XMLParserDelegate {
    var refs: [String] = []
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        guard elementName == "deleted-entry",
              namespaceURI == "http://purl.org/atompub/tombstones/1.0",
              let ref = attributeDict["ref"] else { return }
        refs.append(ref)
    }
}


extension String {

    fileprivate func dropPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
}
