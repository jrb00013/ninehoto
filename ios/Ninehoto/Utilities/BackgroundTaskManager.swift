import Foundation

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private init() {}
    
    func scheduleBackgroundRefresh() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.ninehoto.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            await performBackgroundWork()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func performBackgroundWork() async {
        Logger.shared.info("Performing background refresh")
    }
    
    func requestExtendedExecution() {
        UIApplication.shared.beginExtendedExecution(for: .processing)
    }
}

import BackgroundTasks
import UIKit