import Foundation

final class DataMigrationManager {
    static let shared = DataMigrationManager()
    
    private let currentVersion = 1
    
    private init() {}
    
    func migrateIfNeeded() {
        let lastMigrationVersion = UserDefaults.standard.integer(forKey: "data_migration_version")
        
        if lastMigrationVersion < currentVersion {
            performMigration(from: lastMigrationVersion, to: currentVersion)
            UserDefaults.standard.set(currentVersion, forKey: "data_migration_version")
        }
    }
    
    private func performMigration(from version: Int, to newVersion: Int) {
        Logger.shared.info("Running data migration from version \(version) to \(newVersion)")
        
        if version < 1 {
            migrateToVersion1()
        }
        
        Logger.shared.info("Data migration completed")
    }
    
    private func migrateToVersion1() {
        Logger.shared.info("Migrating to version 1")
        PreferencesManager.shared.clearAll()
    }
    
    func resetMigration() {
        UserDefaults.standard.set(0, forKey: "data_migration_version")
    }
}