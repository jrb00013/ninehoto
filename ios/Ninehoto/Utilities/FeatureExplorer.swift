import Foundation

struct AppFeature: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isEnabled: Bool
}

final class FeatureExplorer {
    static let shared = FeatureExplorer()
    
    private init() {}
    
    var allFeatures: [AppFeature] {
        [
            AppFeature(id: "swipe_undo", name: "Swipe Undo", description: "Undo your last swipe action", icon: "arrow.uturn.backward", isEnabled: FeatureFlags.shared.isSwipeUndoEnabled),
            AppFeature(id: "video_support", name: "Video Support", description: "View and swipe through videos", icon: "video", isEnabled: FeatureFlags.shared.isVideoSupportEnabled),
            AppFeature(id: "haptic_feedback", name: "Haptic Feedback", description: "Feel vibrations on swipe", icon: "hand.tap", isEnabled: FeatureFlags.shared.isHapticFeedbackEnabled),
            AppFeature(id: "fullscreen_preview", name: "Fullscreen Preview", description: "Tap to view fullscreen media", icon: "arrow.up.left.and.arrow.down.right", isEnabled: FeatureFlags.shared.isFullscreenPreviewEnabled),
            AppFeature(id: "thumbnail_prefetch", name: "Thumbnail Prefetch", description: "Pre-load upcoming thumbnails", icon: "photo.stack", isEnabled: FeatureFlags.shared.isThumbnailPrefetchEnabled),
            AppFeature(id: "batch_delete", name: "Batch Delete", description: "Delete multiple items at once", icon: "trash.stack", isEnabled: FeatureFlags.shared.isBatchDeleteEnabled)
        ]
    }
    
    var enabledFeatures: [AppFeature] {
        allFeatures.filter { $0.isEnabled }
    }
    
    func isEnabled(_ featureId: String) -> Bool {
        allFeatures.first { $0.id == featureId }?.isEnabled ?? false
    }
}