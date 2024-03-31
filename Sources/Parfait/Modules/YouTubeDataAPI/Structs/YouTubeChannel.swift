import Foundation


struct YouTubeChannel: Codable {
    
    var etag: String
    
    var id: String
    
    var snippet: YouTubeChannelSnippet
    
    var contentDetails: YouTubeChannelContentDetails?
    
    var statistics: YouTubeChannelStatistics?
    
    var topicDetails: YouTubeChannelTopicDetails?
    
    var status: YouTubeChannelStatus?
    
    var brandingSettings: YouTubeChannelBrandingSettings?
    
    var auditDetails: YouTubeChannelAuditDetails?
    
    var contentOwnerDetails: YouTubeChannelContentOwnerDetails?
    
}

// MARK: - YouTube Channel Snippet

struct YouTubeChannelSnippet: Codable {
    
    var title: String
    
    var description: String
    
    var customURL: String?
    
    var publishedAt: ISO8601FormattedDate
    
    var thumbnails: YouTubeChannelSnippetThumbnails?
    
    var defaultLanguage: String?
    
    var localized: YouTubeChannelSnippetLocalized?
    
    var country: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case customURL = "customUrl"
        case publishedAt
        case thumbnails
        case defaultLanguage
        case localized
        case country
    }
    
}

struct YouTubeChannelSnippetThumbnails: Codable {
    
    var `default`: YouTubeChannelSnippetThumbnail?
    
    var medium: YouTubeChannelSnippetThumbnail?
    
    var high: YouTubeChannelSnippetThumbnail?
    
    enum CodingKeys: String, CodingKey {
        case `default` = "default"
        case medium = "medium"
        case high = "high"
    }
    
}

struct YouTubeChannelSnippetThumbnail: Codable {
    
    var url: String
    
    var width: UInt
    
    var height: UInt
    
}

struct YouTubeChannelSnippetLocalized: Codable {
    
    var title: String
    
    var description: String
    
}

// MARK: - YouTube Channel Content Details

struct YouTubeChannelContentDetails: Codable {
    
    var relatedPlaylists: YouTubeChannelRelatedPlaylists?
    
}

struct YouTubeChannelRelatedPlaylists: Codable {
    
    var likes: String
    
    var uploads: String
    
}

// MARK: - YouTube Channel Statistics

struct YouTubeChannelStatistics: Codable {
    
    var viewCount: StringWithUIntValue
    
    var subscriberCount: StringWithUIntValue
    
    var hiddenSubscriberCount: Bool
    
    var videoCount: StringWithUIntValue
    
}

// MARK: - YouTube Channel Topic Details

struct YouTubeChannelTopicDetails: Codable {
    
    var topicIDs: [String]
    
    var topicCategories: [String]
    
    enum CodingKeys: String, CodingKey {
        case topicIDs = "topicIds"
        case topicCategories = "topicCategories"
    }
    
}

// MARK: - YouTube Channel Status

struct YouTubeChannelStatus: Codable {
    
    var privacyStatus: String
    
    var isLinked: Bool
    
    var longUploadsStatus: String
    
    var madeForKids: Bool
    
    var selfDeclareMadeForKids: Bool
    
    enum CodingKeys: CodingKey {
        case privacyStatus
        case isLinked
        case longUploadsStatus
        case madeForKids
        case selfDeclareMadeForKids
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.privacyStatus = try container.decode(String.self, forKey: .privacyStatus)
        self.isLinked = try container.decode(Bool.self, forKey: .isLinked)
        self.longUploadsStatus = try container.decode(String.self, forKey: .longUploadsStatus)
        self.madeForKids = (
            try? container.decode(Bool.self,
                                  forKey: .madeForKids
                                 )
        ) ?? false
        self.selfDeclareMadeForKids = (
            try? container.decode(Bool.self,
                                  forKey: .selfDeclareMadeForKids
                                 )
        ) ?? false
    }
    
}

// MARK: - YouTube Channel Branding Settings

struct YouTubeChannelBrandingSettings: Codable {
    
    var channel: YouTubeChannelBrandingSettingsChannel?
    
    var watch: YouTubeChannelBrandingSettingsWatch?
    
}

struct YouTubeChannelBrandingSettingsChannel: Codable {
    
    var title: String
    
    var description: String
    
    var keywords: String
    
    var trackingAnalyticsAccountID: String
    
    var moderateComments: String
    
    var unsubscribedTrailer: String
    
    var defaultLanguage: String
    
    var country: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case keywords
        case trackingAnalyticsAccountID = "trackingAnalyticsAccountId"
        case moderateComments
        case unsubscribedTrailer
        case defaultLanguage
        case country
    }
    
}

struct YouTubeChannelBrandingSettingsWatch: Codable {
    
    var textColor: String
    
    var backgroundColor: String
    
    var featuredPlaylistID: String
    
    enum CodingKeys: String, CodingKey {
        case textColor
        case backgroundColor
        case featuredPlaylistID = "featuredPlaylistId"
    }
    
}

// MARK: - YouTube Channel Audit Details

struct YouTubeChannelAuditDetails: Codable {
    
    var overallGoodStanding: Bool
    
    var communityGuidelinesGoodStanding: Bool
    
    var copyrightStrikeGoodStanding: Bool
    
    var contentIDClaimsGoodStanding: Bool
    
    enum CodingKeys: String, CodingKey {
        case overallGoodStanding
        case communityGuidelinesGoodStanding
        case copyrightStrikeGoodStanding
        case contentIDClaimsGoodStanding = "contentIdClaimsGoodStanding"
    }
    
}

// MARK: - YouTube Channel Content Owner Details

struct YouTubeChannelContentOwnerDetails: Codable {
    
    var contentOwner: String
    
    var timeLinked: ISO8601FormattedDate
    
}
