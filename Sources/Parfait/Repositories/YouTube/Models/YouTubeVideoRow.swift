import FluentKit
import Foundation


final class YouTubeVideoRow: Model {
    
    static var schema: String = "youtube_videos"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "video_id")
    var videoID: String
    
    @Field(key: "channel_id")
    var channelID: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "url")
    var url: URL
    
    @Field(key: "thumbnail_url")
    var thumbnailURL: URL?
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "published_at")
    var publishedAt: Date?
    
    @Field(key: "scheduled_at")
    var scheduledAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
}


extension YouTubeVideo {
    
    @discardableResult
    func save(on db: Database) async throws -> YouTubeVideoRow {
        let row = try await YouTubeVideoRow.query(on: db)
            .filter(\.$videoID == self.id)
            .first() ?? YouTubeVideoRow()
        row.videoID = self.id
        row.channelID = self.snippet.channelID
        row.title = self.snippet.title
        row.url = try "https://www.youtube.com/watch?v=\(self.id)".convertToURL()
        row.thumbnailURL = try self.snippet.thumbnails?.high?.url.convertToURL()
        row.description = self.snippet.description
        row.publishedAt = self.snippet.publishedAt.date
        row.scheduledAt = self.liveStreamingDetails?.scheduledStartTime.date
        try await row.save(on: db)
        return row
    }
    
}


struct CreateYouTubeVideosTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(YouTubeVideoRow.schema)
            .id()
            .field("video_id", .string, .required)
            .field("channel_id", .string, .required)
            .field("title", .string, .required)
            .field("url", .string, .required)
            .field("thumbnail_url", .string)
            .field("description", .sql(raw: "TEXT"))
            .field("published_at", .datetime)
            .field("scheduled_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "video_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(YouTubeVideoRow.schema).delete()
    }
    
}


extension Substring {
    
    fileprivate var string: String? {
        return String(self)
    }
    
}
