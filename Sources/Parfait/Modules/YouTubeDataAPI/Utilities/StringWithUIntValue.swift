import Foundation


enum StringWithUIntValue {
    case parsed(UInt, String?)
    case raw(String?)
    
    var value: UInt? {
        switch self {
        case .parsed(let parsed, _):
            return parsed
        default:
            return nil
        }
    }
    
    var raw: String? {
        switch self {
        case .parsed(_, let raw):
            return raw
        case .raw(let raw):
            return raw
        }
    }
}


extension StringWithUIntValue: Codable {
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .raw(nil)
            return
        }
        if let value = try? container.decode(UInt.self) {
            self = .parsed(value, nil)
            return
        }
        guard let raw = try? container.decode(String.self) else {
            self = .raw(nil)
            return
        }
        if let value = UInt(raw) {
            self = .parsed(value, raw)
            return
        }
        self = .raw(raw)
    }
}
