import Foundation

final class UserActivityManager {
    static let shared = UserActivityManager()
    
    private init() {}
    
    func startActivity(type: String, userInfo: [String: Any] = [:]) {
        let activity = NSUserActivity(activityType: type)
        activity.title = type
        activity.userInfo = userInfo
        activity.becomeCurrent()
    }
    
    func updateActivity(userInfo: [String: Any]) {
        NSUserActivity.current?.addUserInfoEntries(from: userInfo)
    }
    
    func endActivity() {
        NSUserActivity.current?.invalidate()
    }
    
    func continueActivity(_ userActivity: NSUserActivity) {
        // Handle continued activity
    }
}