using System;

namespace Ninehoto.Android.Utilities
{
    public class FeatureFlags
    {
        private static FeatureFlags? _instance;
        public static FeatureFlags Instance => _instance ??= new FeatureFlags();

        private readonly Android.Content.ISharedPreferences _prefs;
        private const string Prefix = "feature_";

        private FeatureFlags()
        {
            _prefs = Android.App.Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private);
        }

        // Core Features
        public bool IsSwipeUndoEnabled => GetBool("swipe_undo", true);
        public bool IsVideoSupportEnabled => GetBool("video_support", true);
        public bool IsHapticFeedbackEnabled => GetBool("haptic_feedback", true);
        public bool IsFullscreenPreviewEnabled => GetBool("fullscreen_preview", true);

        // Experimental Features
        public bool IsThumbnailPrefetchEnabled => GetBool("thumbnail_prefetch", true);
        public bool IsSmartSortEnabled => GetBool("smart_sort", false);
        public bool IsBatchDeleteEnabled => GetBool("batch_delete", true);
        public bool IsSessionAnalyticsEnabled => GetBool("session_analytics", false);

        // UI Features
        public bool IsDarkModeOnly => GetBool("dark_mode_only", true);
        public bool IsAnimatedTransitionsEnabled => GetBool("animated_transitions", true);
        public bool IsPullToRefreshEnabled => GetBool("pull_to_refresh", false);

        // Debug Features
        public bool IsDebugLoggingEnabled => GetBool("debug_logging", false);
        public bool IsPerformanceMetricsEnabled => GetBool("performance_metrics", false);
        public bool IsMockDataEnabled => GetBool("mock_data", false);

        public void SetFeature(string feature, bool enabled)
        {
            _prefs.Edit().PutBoolean(Prefix + feature, enabled).Apply();
        }

        public bool IsFeatureEnabled(string feature)
        {
            return _prefs.GetBoolean(Prefix + feature, false);
        }

        public void ResetAllFeatures()
        {
            var editor = _prefs.Edit();
            foreach (var key in _prefs.All.Keys)
            {
                if (key.StartsWith(Prefix))
                    editor.Remove(key);
            }
            editor.Apply();
        }

        private bool GetBool(string key, bool defaultValue)
        {
            var fullKey = Prefix + key;
            if (!_prefs.Contains(fullKey))
                return defaultValue;
            return _prefs.GetBoolean(fullKey, defaultValue);
        }
    }

    public enum FeatureName
    {
        SwipeUndo,
        VideoSupport,
        HapticFeedback,
        FullscreenPreview,
        ThumbnailPrefetch,
        SmartSort,
        BatchDelete,
        SessionAnalytics,
        DarkModeOnly,
        AnimatedTransitions,
        PullToRefresh,
        DebugLogging,
        PerformanceMetrics,
        MockData
    }
}