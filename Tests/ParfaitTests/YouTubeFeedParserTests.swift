import XCTest
@testable import Parfait


private struct TestParser: YouTubeFeedParser {}


final class YouTubeFeedParserTests: XCTestCase {

    func testParseNormalVideoFeed() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom"
              xmlns:yt="http://www.youtube.com/xml/schemas/2015">
          <entry>
            <yt:videoId>VIDEO_ID_123</yt:videoId>
            <yt:channelId>CHANNEL_ID_456</yt:channelId>
            <author><name>Test Channel</name></author>
            <title>Test Video Title</title>
            <published>2024-01-15T10:00:00+00:00</published>
          </entry>
        </feed>
        """
        let data = Data(xmlString.utf8)
        let parser = TestParser()
        let result = parser.parseYouTubeFeed(from: data)

        guard case let .success(feed) = result else {
            XCTFail("Expected success but got failure")
            return
        }
        guard case let .youTubeVideos(videos) = feed else {
            XCTFail("Expected .youTubeVideos but got \(feed)")
            return
        }
        XCTAssertEqual(videos.count, 1)
        let video = videos[0]
        XCTAssertEqual(video.videoID, "VIDEO_ID_123")
        XCTAssertEqual(video.channelID, "CHANNEL_ID_456")
        XCTAssertEqual(video.videoTitle, "Test Video Title")
        XCTAssertEqual(video.channelName, "Test Channel")
    }

    func testParseDeletedEntryFeed() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom"
              xmlns:at="http://purl.org/atompub/tombstones/1.0">
          <at:deleted-entry ref="yt:video:VIDEO123" when="2024-01-15T10:00:00+00:00"/>
        </feed>
        """
        let data = Data(xmlString.utf8)
        let parser = TestParser()
        let result = parser.parseYouTubeFeed(from: data)

        guard case let .success(feed) = result else {
            XCTFail("Expected success but got failure")
            return
        }
        guard case let .deletedYouTubeVideos(videos) = feed else {
            XCTFail("Expected .deletedYouTubeVideos but got \(feed)")
            return
        }
        XCTAssertEqual(videos.count, 1)
        XCTAssertEqual(videos[0].videoID, "VIDEO123")
    }

    func testParseEmptyFeed() {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
        </feed>
        """
        let data = Data(xmlString.utf8)
        let parser = TestParser()
        let result = parser.parseYouTubeFeed(from: data)

        guard case let .success(feed) = result else {
            XCTFail("Expected success but got failure")
            return
        }
        guard case .empty = feed else {
            XCTFail("Expected .empty but got \(feed)")
            return
        }
    }

}
