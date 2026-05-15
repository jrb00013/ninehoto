import Foundation

final class ScreenRecorderDetector {
    static let shared = ScreenRecorderDetector()
    
    private var isRecording = false
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        updateStatus()
    }
    
    @objc private func screenCaptureChanged() {
        updateStatus()
        if isRecording {
            NotificationCenter.default.post(name: .screenRecordingStarted, object: nil)
        } else {
            NotificationCenter.default.post(name: .screenRecordingStopped, object: nil)
        }
    }
    
    private func updateStatus() {
        isRecording = UIScreen.main.isCaptured
    }
    
    var isCurrentlyRecording: Bool {
        isRecording
    }
}

extension Notification.Name {
    static let screenRecordingStarted = Notification.Name("screenRecordingStarted")
    static let screenRecordingStopped = Notification.Name("screenRecordingStopped")
}

import UIKit