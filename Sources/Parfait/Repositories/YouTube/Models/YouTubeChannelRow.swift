import FluentKit
import Foundation


final class YouTubeChannelRow: Model {
    
    static var schema: String = "youtube_channels"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "channel_id")
    var channelID: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "url")
    var url: URL
    
    @Field(key: "thumbnail_url")
    var thumbnailURL: URL?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
}


extension YouTubeChannel {
    
    @discardableResult
    func save(on db: Database) async throws -> YouTubeChannelRow {
        let row = try await YouTubeChannelRow.query(on: db)
            .filter(\.$channelID == self.id)
            .first() ?? YouTubeChannelRow()
        row.channelID = self.id
        row.title = self.snippet.title
        row.url = try "https://www.youtube.com/channel/\(self.id)".convertToURL()
        row.thumbnailURL = try self.snippet.thumbnails?.high?.url.convertToURL()
        try await row.save(on: db)
        return row
    }
    
}


struct CreateYouTubeChannelsTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(YouTubeChannelRow.schema)
            .id()
            .field("channel_id", .string, .required)
            .field("title", .string, .required)
            .field("url", .string, .required)
            .field("thumbnail_url", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "channel_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(YouTubeChannelRow.schema).delete()
    }
    
}
