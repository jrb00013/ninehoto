import Foundation

final class SearchIndexManager {
    static let shared = SearchIndexManager()
    
    private var index: [String: [String]] = [:]
    
    private init() {}
    
    func index(_ items: [MediaItem], for query: String) {
        let lowercasedQuery = query.lowercased()
        
        index[lowercasedQuery] = items.compactMap { item in
            if item.id.lowercased().contains(lowercasedQuery) {
                return item.id
            }
            return nil
        }
    }
    
    func search(_ query: String) -> [String] {
        let lowercasedQuery = query.lowercased()
        return index[lowercasedQuery] ?? []
    }
    
    func clearIndex() {
        index.removeAll()
    }
    
    func rebuildIndex(with items: [MediaItem]) {
        clearIndex()
        
        for item in items {
            let keywords = item.id.components(separatedBy: " ")
            for keyword in keywords {
                index(keyword.lowercased(), for: item.id)
            }
        }
    }
}