using System;
using System.Collections.Generic;

namespace Ninehoto.Android.Models
{
    public class SessionStatistics
    {
        public int SwipeCount { get; set; }
        public int DeleteCount { get; set; }
        public int KeepCount { get; set; }
        public DateTime SessionDate { get; set; }
        public double DurationSeconds { get; set; }
        public double AverageSwipesPerMinute { get; set; }
        public long SpaceSavedBytes { get; set; }

        public static SessionStatistics Empty => new SessionStatistics
        {
            SwipeCount = 0,
            DeleteCount = 0,
            KeepCount = 0,
            SessionDate = DateTime.Now,
            DurationSeconds = 0,
            AverageSwipesPerMinute = 0,
            SpaceSavedBytes = 0
        };

        public double DeleteRate => SwipeCount > 0 ? (double)DeleteCount / SwipeCount * 100 : 0;
        public double KeepRate => SwipeCount > 0 ? (double)KeepCount / SwipeCount * 100 : 0;

        public string FormattedDuration
        {
            get
            {
                var minutes = (int)DurationSeconds / 60;
                var seconds = (int)DurationSeconds % 60;
                return minutes > 0 ? $"{minutes}m {seconds}s" : $"{seconds}s";
            }
        }
    }

    public class StatisticsTracker
    {
        private const string KeyPrefix = "statistics_";
        private readonly Android.Content.ISharedPreferences _prefs;

        public StatisticsTracker(Android.Content.ISharedPreferences prefs)
        {
            _prefs = prefs;
        }

        public void SaveSession(SessionStatistics statistics)
        {
            var key = KeyPrefix + statistics.SessionDate.ToString("yyyy-MM-dd");
            var json = Newtonsoft.Json.JsonConvert.SerializeObject(statistics);
            _prefs.Edit().PutString(key, json).Apply();
        }

        public List<SessionStatistics> GetAllSessions()
        {
            var sessions = new List<SessionStatistics>();
            var allEntries = _prefs.All;

            foreach (var entry in allEntries)
            {
                if (entry.Key.StartsWith(KeyPrefix) && entry.Value is string json)
                {
                    try
                    {
                        var stats = Newtonsoft.Json.JsonConvert.DeserializeObject<SessionStatistics>(json);
                        if (stats != null) sessions.Add(stats);
                    }
                    catch { }
                }
            }

            sessions.Sort((a, b) => b.SessionDate.CompareTo(a.SessionDate));
            return sessions;
        }

        public SessionStatistics GetTotalStatistics()
        {
            var sessions = GetAllSessions();
            var total = SessionStatistics.Empty;

            foreach (var session in sessions)
            {
                total.SwipeCount += session.SwipeCount;
                total.DeleteCount += session.DeleteCount;
                total.KeepCount += session.KeepCount;
                total.DurationSeconds += session.DurationSeconds;
                total.SpaceSavedBytes += session.SpaceSavedBytes;
            }

            total.AverageSwipesPerMinute = total.DurationSeconds > 0 
                ? total.SwipeCount / (total.DurationSeconds / 60) 
                : 0;

            return total;
        }

        public void ClearAll()
        {
            var editor = _prefs.Edit();
            var keys = new List<string>();
            
            foreach (var entry in _prefs.All)
            {
                if (entry.Key.StartsWith(KeyPrefix))
                    keys.Add(entry.Key);
            }

            foreach (var key in keys)
                editor.Remove(key);
            
            editor.Apply();
        }
    }
}