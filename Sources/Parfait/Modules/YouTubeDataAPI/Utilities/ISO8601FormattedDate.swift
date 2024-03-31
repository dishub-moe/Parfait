import Foundation


enum ISO8601FormattedDate {
    case parsed(Date, String)
    case fail(String?)
}


extension ISO8601FormattedDate: Codable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .fail(nil)
            return
        }
        guard let raw = try? container.decode(String.self) else {
            self  = .fail(nil)
            return
        }
        if let date = DateFormatter.ISO8601_1.date(from: raw) {
            self = .parsed(date, raw)
            return
        }
        if let date = DateFormatter.ISO8601_2.date(from: raw) {
            self = .parsed(date, raw)
            return
        }
        self = .fail(raw)
    }
    
    var date: Date? {
        switch self {
        case .parsed(let date, _):
            return date
        default:
            return nil
        }
    }
}


extension DateFormatter {
    
    fileprivate static let ISO8601_1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    fileprivate static let ISO8601_2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return formatter
    }()
    
}
