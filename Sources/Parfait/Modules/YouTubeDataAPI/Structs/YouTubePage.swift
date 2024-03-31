import Foundation


struct YouTubePage<Item: Codable>: Codable {
    
    let etag: String
    
    let items: [Item]
    
    let pageInfo: YouTubePageInfo
    
}

struct YouTubePageInfo: Codable {
    
    let totalResults: UInt
    
    let resultsPerPage: UInt
    
}
