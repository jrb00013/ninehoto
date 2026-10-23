import Foundation

final class UserActivityManager {
    static let shared = UserActivityManager()
    
    private var currentActivity: NSUserActivity?

    private init() {}
    
    func startActivity(type: String, userInfo: [String: Any] = [:]) {
        let activity = NSUserActivity(activityType: type)
        activity.title = type
        activity.userInfo = userInfo
        activity.becomeCurrent()
        currentActivity = activity
    }
    
    func updateActivity(userInfo: [String: Any]) {
        currentActivity?.addUserInfoEntries(from: userInfo)
    }
    
    func endActivity() {
        currentActivity?.invalidate()
    }
    
    func continueActivity(_ userActivity: NSUserActivity) {
        // Handle continued activity
    }
}