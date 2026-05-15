import Foundation

final class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.ninehoto.app")
    }
    
    var isAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
    
    func saveRecord(_ record: CKRecord) async throws {
        let privateDatabase = container.privateCloudDatabase
        try await privateDatabase.save(record)
    }
    
    func fetchRecord(withID recordID: CKRecord.ID) async throws -> CKRecord {
        let privateDatabase = container.privateCloudDatabase
        return try await privateDatabase.record(for: recordID)
    }
    
    func deleteRecord(withID recordID: CKRecord.ID) async throws {
        let privateDatabase = container.privateCloudDatabase
        try await privateDatabase.deleteRecord(withID: recordID)
    }
}

import CloudKit