using System;
using Android.Content;
using Ninehoto.Android.Interfaces;

namespace Ninehoto.Android.Services
{
    public class PreferencesService : IPreferencesService
    {
        private readonly ISharedPreferences _prefs;
        
        private const string KeyHasCompletedOnboarding = "hasCompletedOnboarding";
        private const string KeyLastSessionDate = "lastSessionDate";
        private const string KeySwipeCount = "swipeCount";
        private const string KeyDeleteCount = "deleteCount";
        private const string KeyKeepCount = "keepCount";
        private const string KeyHapticFeedbackEnabled = "hapticFeedbackEnabled";
        private const string KeyPreferredSortOrder = "preferredSortOrder";
        private const string KeyThumbnailQuality = "thumbnailQuality";

        public PreferencesService(ISharedPreferences prefs)
        {
            _prefs = prefs;
        }

        public bool HasCompletedOnboarding
        {
            get => _prefs.GetBoolean(KeyHasCompletedOnboarding, false);
            set => _prefs.Edit().PutBoolean(KeyHasCompletedOnboarding, value).Apply();
        }

        public DateTime? LastSessionDate
        {
            get
            {
                var ticks = _prefs.GetLong(KeyLastSessionDate, 0);
                return ticks > 0 ? new DateTime(ticks, DateTimeKind.Utc) : null;
            }
            set
            {
                if (value.HasValue)
                    _prefs.Edit().PutLong(KeyLastSessionDate, value.Value.Ticks).Apply();
                else
                    _prefs.Edit().Remove(KeyLastSessionDate).Apply();
            }
        }

        public int SwipeCount
        {
            get => _prefs.GetInt(KeySwipeCount, 0);
            set => _prefs.Edit().PutInt(KeySwipeCount, value).Apply();
        }

        public int DeleteCount
        {
            get => _prefs.GetInt(KeyDeleteCount, 0);
            set => _prefs.Edit().PutInt(KeyDeleteCount, value).Apply();
        }

        public int KeepCount
        {
            get => _prefs.GetInt(KeyKeepCount, 0);
            set => _prefs.Edit().PutInt(KeyKeepCount, value).Apply();
        }

        public bool HapticFeedbackEnabled
        {
            get
            {
                if (!_prefs.Contains(KeyHapticFeedbackEnabled))
                    return true;
                return _prefs.GetBoolean(KeyHapticFeedbackEnabled, true);
            }
            set => _prefs.Edit().PutBoolean(KeyHapticFeedbackEnabled, value).Apply();
        }

        public void ResetStatistics()
        {
            SwipeCount = 0;
            DeleteCount = 0;
            KeepCount = 0;
        }
    }

    public enum SortOrder
    {
        DateDescending = 0,
        DateAscending = 1,
        CreationDateDescending = 2
    }

    public enum ThumbnailQuality
    {
        Low = 0,
        Medium = 1,
        High = 2
    }
}