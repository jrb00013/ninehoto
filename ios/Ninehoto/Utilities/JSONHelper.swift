import Foundation

final class JSONHelper {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }
    
    static func decode<T: Decodable>(_ data: Data, as type: T.Type) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }
    
    static func encodeToString<T: Encodable>(_ value: T) -> String? {
        guard let data = encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func decodeFromString<T: Decodable>(_ string: String, as type: T.Type) -> T? {
        guard let data = string.data(using: .utf8) else { return nil }
        return decode(data, as: type)
    }
    
    static func prettyPrint<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Encodable {
    func toJSON() -> String? {
        JSONHelper.encodeToString(self)
    }
    
    func toPrettyJSON() -> String? {
        JSONHelper.prettyPrint(self)
    }
    
    func toData() -> Data? {
        JSONHelper.encode(self)
    }
}

extension Data {
    func decode<T: Decodable>(as type: T.Type) -> T? {
        JSONHelper.decode(self, as: type)
    }
}

extension String {
    func decodeJSON<T: Decodable>(as type: T.Type) -> T? {
        JSONHelper.decodeFromString(self, as: type)
    }
}