import Foundation


struct YouTubeVideo: Codable {
    
    var etag: String
    
    var id: String
    
    var snippet: YouTubeVideoSnippet
    
    var contentDetails: YouTubeVideoContentDetails
    
    var status: YouTubeVideoStatus
    
    var statistics: YouTubeVideoStatistics
    
    var liveStreamingDetails: YouTubeVideoLiveStreamingDetails?
    
}

// MARK: - YouTube Video Snippet

struct YouTubeVideoSnippet: Codable {
    
    var publishedAt: ISO8601FormattedDate
    
    var channelID: String
    
    var title: String
    
    var description: String
    
    var thumbnails: YouTubeVideoThumbnails?
    
    var channelTitle: String
    
    var categoryID: String
    
    var liveBroadcastContent: LiveBroadcastContent
    
    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID = "channelId"
        case title
        case description
        case thumbnails
        case channelTitle
        case categoryID = "categoryId"
        case liveBroadcastContent
    }
    
}

enum LiveBroadcastContent: String, Codable, UnknownDecodable {
    case live
    case upcoming
    case unknown
}

// MARK: - YouTube Video Thumbnails

struct YouTubeVideoThumbnails: Codable {
    
    var `default`: YouTubeVideoThumbnail?
    
    var medium: YouTubeVideoThumbnail?
    
    var high: YouTubeVideoThumbnail?
    
}

// MARK: - YouTube Video Thumbnail

struct YouTubeVideoThumbnail: Codable {
    
    var url: String
    
    var width: UInt
    
    var height: UInt
    
}

// MARK: - YouTube Video Content Details

struct YouTubeVideoContentDetails: Codable {
    
    var duration: Duration
    
    var dimension: YouTubeVideContentDimension
    
    var definition: YouTubeVideoContentDefinition
    
    var caption: YouTubeVideoContentCaption
    
    var licensedContent: Bool
    
    var projection: YouTubeVideoContentProjection
    
}

enum Duration {
    case parsed(days: UInt, hours: UInt, minutes: UInt, seconds: UInt)
    case fail(raw: String?)
}

extension Duration: Codable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .fail(raw: nil)
            return
        }
        guard var raw = try? container.decode(String.self) else {
            self  = .fail(raw: nil)
            return
        }
        if raw.hasPrefix("P") { raw.removeFirst(1) }
        let days, hours, minutes, seconds: UInt
        if let index = raw.firstIndex(of: "D") {
            days = UInt(raw[..<index]) ?? 0
            raw.removeSubrange(...index)
        } else { days = 0 }
        if raw.hasPrefix("T") { raw.removeFirst(1) }
        if let index = raw.firstIndex(of: "H") {
            hours = UInt(raw[..<index]) ?? 0
            raw.removeSubrange(...index)
        } else { hours = 0 }
        if let index = raw.firstIndex(of: "M") {
            minutes = UInt(raw[..<index]) ?? 0
            raw.removeSubrange(...index)
        } else { minutes = 0 }
        if let index = raw.firstIndex(of: "S") {
            seconds = UInt(raw[..<index]) ?? 0
        } else { seconds = 0 }
        self = .parsed(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }
}

enum YouTubeVideContentDimension {
    case threeDimension
    
    case twoDimension
    
    case fail(String?)
}

extension YouTubeVideContentDimension: Codable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .fail(nil)
            return
        }
        guard let raw = try? container.decode(String.self) else {
            self  = .fail(nil)
            return
        }
        switch raw {
        case "3d":
            self = .threeDimension
        case "2d":
            self = .twoDimension
        default:
            self = .fail(raw)
        }
    }
}

enum YouTubeVideoContentDefinition: String, Codable, UnknownDecodable {
    case hd
    case sd
    case unknown
}

enum YouTubeVideoContentCaption: String, Codable, UnknownDecodable {
    case `true`
    case `false`
    case unknown
}

enum YouTubeVideoContentProjection {
    case threeHundredSixty
    case rectangular
    case fail(String?)
}

extension YouTubeVideoContentProjection: Codable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .fail(nil)
            return
        }
        guard let raw = try? container.decode(String.self) else {
            self  = .fail(nil)
            return
        }
        switch raw {
        case "360":
            self = .threeHundredSixty
        case "rectangular":
            self = .rectangular
        default:
            self = .fail(raw)
        }
    }
}

// MARK: - YouTube Video Status

struct YouTubeVideoStatus: Codable {
    
    var uploadStatus: YouTubeVideoUploadStatus
    
    var privacyStatus: YouTubeVideoPrivacyStatus
    
    var license: YouTubeVideoLicense
    
    var embeddable: Bool
    
    var publicStatsViewable: Bool
    
    var madeForKids: Bool
    
}

enum YouTubeVideoUploadStatus: String, Codable, UnknownDecodable {
    case deleted
    case failed
    case processed
    case rejected
    case uploaded
    case unknown
}

enum YouTubeVideoPrivacyStatus: String, Codable, UnknownDecodable {
    case `private`
    case `public`
    case unlisted
    case unknown
}

enum YouTubeVideoLicense: String, Codable, UnknownDecodable {
    case creativeCommon
    case youTube
    case unknown
}

// MARK: - YouTube Video Statistics

struct YouTubeVideoStatistics: Codable {
    
    var viewCount: StringWithUIntValue
    
    var likeCount: StringWithUIntValue
    
    var commentCount: StringWithUIntValue
    
}

// MARK: - YouTube Video Live Streaming Details

struct YouTubeVideoLiveStreamingDetails: Codable {
    
    var scheduledStartTime: ISO8601FormattedDate
    
    var activeLiveChatID: String?
    
    enum CodingKeys: String, CodingKey {
        case scheduledStartTime = "scheduledStartTime"
        case activeLiveChatID = "activeLiveChatId"
    }
    
}
