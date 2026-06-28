import XCTest
@testable import Parfait


final class YouTubeVideoStatusTests: XCTestCase {
    private let decoder = JSONDecoder()

    func testDecodesStatusMissingMadeForKids() throws {
        let json = """
        {
            "uploadStatus": "processed",
            "privacyStatus": "public",
            "license": "youtube",
            "embeddable": true,
            "publicStatsViewable": true
        }
        """
        let status = try decoder.decode(YouTubeVideoStatus.self, from: Data(json.utf8))
        XCTAssertFalse(status.madeForKids)
        XCTAssertTrue(status.embeddable)
        XCTAssertTrue(status.publicStatsViewable)
    }

    func testDecodesStatusMissingAllBools() throws {
        let json = """
        {
            "uploadStatus": "processed",
            "privacyStatus": "public",
            "license": "youtube"
        }
        """
        let status = try decoder.decode(YouTubeVideoStatus.self, from: Data(json.utf8))
        XCTAssertFalse(status.embeddable)
        XCTAssertFalse(status.publicStatsViewable)
        XCTAssertFalse(status.madeForKids)
    }

    func testDecodesFullStatusWithMadeForKidsTrue() throws {
        let json = """
        {
            "uploadStatus": "processed",
            "privacyStatus": "public",
            "license": "youtube",
            "embeddable": true,
            "publicStatsViewable": true,
            "madeForKids": true
        }
        """
        let status = try decoder.decode(YouTubeVideoStatus.self, from: Data(json.utf8))
        XCTAssertTrue(status.madeForKids)
        XCTAssertTrue(status.embeddable)
        XCTAssertTrue(status.publicStatsViewable)
    }
}
