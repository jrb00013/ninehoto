using System;
using System.Collections.Generic;
using Ninehoto.Android.Utilities;

namespace Ninehoto.Android.Services
{
    public class AnalyticsService
    {
        private static AnalyticsService? _instance;
        public static AnalyticsService Instance => _instance ??= new AnalyticsService();

        private readonly Android.Content.ISharedPreferences _prefs;
        private const string KeyEvents = "analytics_events";

        private AnalyticsService()
        {
            _prefs = Android.App.Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private);
        }

        public void TrackEvent(AnalyticsEvent analyticsEvent)
        {
            if (!FeatureFlags.Instance.IsSessionAnalyticsEnabled)
                return;

            var events = LoadEvents();
            events.Add(analyticsEvent);
            SaveEvents(events);

            var loggingService = new LoggingService();
            loggingService.Info($"Analytics: {analyticsEvent.Name}");
        }

        public void TrackSessionStart()
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "session_start",
                Properties = new Dictionary<string, object>
                {
                    { "timestamp", DateTime.Now.Ticks }
                }
            });
        }

        public void TrackSessionEnd(int swipeCount, int deleteCount, int keepCount)
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "session_end",
                Properties = new Dictionary<string, object>
                {
                    { "swipe_count", swipeCount },
                    { "delete_count", deleteCount },
                    { "keep_count", keepCount },
                    { "duration", DateTime.Now.Ticks }
                }
            });
        }

        public void TrackSwipe(string direction, int index)
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "swipe",
                Properties = new Dictionary<string, object>
                {
                    { "direction", direction },
                    { "index", index }
                }
            });
        }

        public void TrackUndo()
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "undo",
                Properties = new Dictionary<string, object>()
            });
        }

        public void TrackDeleteConfirmation(int count)
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "delete_confirmation",
                Properties = new Dictionary<string, object>
                {
                    { "count", count }
                }
            });
        }

        public void TrackDeleteSuccess(int count)
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "delete_success",
                Properties = new Dictionary<string, object>
                {
                    { "count", count }
                }
            });
        }

        public void TrackPermissionDenied()
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "permission_denied",
                Properties = new Dictionary<string, object>()
            });
        }

        public void TrackError(string errorType)
        {
            TrackEvent(new AnalyticsEvent
            {
                Name = "error",
                Properties = new Dictionary<string, object>
                {
                    { "type", errorType }
                }
            });
        }

        public List<AnalyticsEvent> GetEvents()
        {
            return LoadEvents();
        }

        public void ClearEvents()
        {
            _prefs.Edit().Remove(KeyEvents).Apply();
        }

        public int GetSessionCount()
        {
            int count = 0;
            foreach (var evt in LoadEvents())
            {
                if (evt.Name == "session_start")
                    count++;
            }
            return count;
        }

        public int GetTotalSwipes()
        {
            int count = 0;
            foreach (var evt in LoadEvents())
            {
                if (evt.Name == "swipe")
                    count++;
            }
            return count;
        }

        private List<AnalyticsEvent> LoadEvents()
        {
            var json = _prefs.GetString(KeyEvents, "[]");
            try
            {
                return Newtonsoft.Json.JsonConvert.DeserializeObject<List<AnalyticsEvent>>(json) ?? new List<AnalyticsEvent>();
            }
            catch
            {
                return new List<AnalyticsEvent>();
            }
        }

        private void SaveEvents(List<AnalyticsEvent> events)
        {
            var json = Newtonsoft.Json.JsonConvert.SerializeObject(events);
            _prefs.Edit().PutString(KeyEvents, json).Apply();
        }
    }

    public class AnalyticsEvent
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string Name { get; set; } = "";
        public Dictionary<string, object> Properties { get; set; } = new();
        public long Timestamp { get; set; } = DateTime.Now.Ticks;

        public DateTime GetTimestamp() => new DateTime(Timestamp);
    }
}