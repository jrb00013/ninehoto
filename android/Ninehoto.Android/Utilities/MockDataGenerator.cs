using System;
using System.Collections.Generic;
using Ninehoto.Android.Models;

namespace Ninehoto.Android.Utilities
{
    public class MockDataGenerator
    {
        private static MockDataGenerator? _instance;
        public static MockDataGenerator Instance => _instance ??= new MockDataGenerator();

        private MockDataGenerator() { }

        public List<MediaItem> GenerateMockMediaItems(int count, bool includeVideos = true)
        {
            var items = new List<MediaItem>();

            for (int i = 0; i < count; i++)
            {
                var isVideo = includeVideos && (i % 5 == 0);
                var item = new MediaItem
                {
                    Id = $"mock-asset-{i}-{Guid.NewGuid()}",
                    MediaType = isVideo ? MediaItem.MediaType.Video : MediaItem.MediaType.Photo,
                    CreationDate = DateTime.Now.AddDays(-i),
                    PixelWidth = new Random().Next(1000, 4000),
                    PixelHeight = new Random().Next(1000, 4000),
                    IsVideo = isVideo
                };

                if (isVideo)
                {
                    item.Duration = new Random().Next(5, 300);
                }

                items.Add(item);
            }

            return items;
        }

        public List<SessionStatistics> GenerateMockStatistics(int count)
        {
            var sessions = new List<SessionStatistics>();
            var random = new Random();

            for (int i = 0; i < count; i++)
            {
                var swipeCount = random.Next(20, 200);
                var deleteCount = random.Next(0, swipeCount);
                var keepCount = swipeCount - deleteCount;
                var duration = random.Next(60, 600);

                var session = new SessionStatistics
                {
                    SwipeCount = swipeCount,
                    DeleteCount = deleteCount,
                    KeepCount = keepCount,
                    SessionDate = DateTime.Now.AddDays(-i * 7),
                    DurationSeconds = duration,
                    AverageSwipesPerMinute = swipeCount / (duration / 60.0)
                };

                sessions.Add(session);
            }

            return sessions;
        }

        public UserPreferences GenerateMockUserPreferences()
        {
            var random = new Random();
            var qualityValues = Enum.GetValues(typeof(ThumbnailQuality));
            var sortValues = Enum.GetValues(typeof(SortOrder));

            return new UserPreferences
            {
                HapticFeedbackEnabled = random.Next(2) == 1,
                ThumbnailQuality = (ThumbnailQuality)qualityValues.GetValue(random.Next(qualityValues.Length)),
                SortOrder = (SortOrder)sortValues.GetValue(random.Next(sortValues.Length)),
                HasCompletedOnboarding = true,
                LastSessionDate = DateTime.Now.AddDays(-random.Next(0, 7))
            };
        }
    }

    public class UserPreferences
    {
        public bool HapticFeedbackEnabled { get; set; }
        public ThumbnailQuality ThumbnailQuality { get; set; }
        public SortOrder SortOrder { get; set; }
        public bool HasCompletedOnboarding { get; set; }
        public DateTime? LastSessionDate { get; set; }
    }
}