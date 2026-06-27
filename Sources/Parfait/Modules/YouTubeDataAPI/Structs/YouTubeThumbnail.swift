import Foundation


struct YouTubeThumbnails: Codable {
    var `default`: YouTubeThumbnail?
    var medium: YouTubeThumbnail?
    var high: YouTubeThumbnail?
}

struct YouTubeThumbnail: Codable {
    var url: String
    var width: UInt
    var height: UInt
}
