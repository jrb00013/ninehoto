using System;
using System.Collections.Generic;

namespace Ninehoto.Android.Models
{
    public class Trip
    {
        public string Id { get; }
        public string Name { get; }
        public DateTime StartDate { get; }
        public DateTime EndDate { get; }
        public double? CenterLatitude { get; }
        public double? CenterLongitude { get; }
        public int AssetCount { get; }

        public Trip(string id, string name, DateTime start, DateTime end, double? lat, double? lon, int count)
        {
            Id = id;
            Name = name;
            StartDate = start;
            EndDate = end;
            CenterLatitude = lat;
            CenterLongitude = lon;
            AssetCount = count;
        }
    }

    public class SessionFilter
    {
        public string? BucketName { get; set; }
        public Trip? SelectedTrip { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }

        public bool IsActive => BucketName != null || SelectedTrip != null || DateFrom != null;

        public string Label => SelectedTrip?.Name ?? BucketName ?? "All photos";
    }

    public static class TripDetector
    {
        public static List<Trip> DetectTrips(List<MediaItem> items)
        {
            if (items.Count == 0) return new List<Trip>();

            var sorted = items.OrderBy(i => i.DateAddedSec).ToList();
            var trips = new List<Trip>();
            var current = new List<MediaItem> { sorted[0] };

            for (int i = 1; i < sorted.Count; i++)
            {
                var prev = sorted[i - 1];
                var curr = sorted[i];
                long gapHours = (curr.DateAddedSec - prev.DateAddedSec) / 3600;

                if (gapHours < 48)
                {
                    current.Add(curr);
                }
                else
                {
                    var trip = MakeTrip(current);
                    if (trip != null) trips.Add(trip);
                    current = new List<MediaItem> { curr };
                }
            }

            var lastTrip = MakeTrip(current);
            if (lastTrip != null) trips.Add(lastTrip);

            return trips;
        }

        private static Trip? MakeTrip(List<MediaItem> items)
        {
            if (items.Count == 0) return null;

            var start = DateTimeOffset.FromUnixTimeSeconds(items[0].DateAddedSec).DateTime;
            var end = DateTimeOffset.FromUnixTimeSeconds(items[^1].DateAddedSec).DateTime;

            var withLocation = items.Where(i => !double.IsNaN(i.Latitude)).ToList();
            double? avgLat = withLocation.Count > 0 ? withLocation.Average(i => i.Latitude) : null;
            double? avgLon = withLocation.Count > 0 ? withLocation.Average(i => i.Longitude) : null;

            return new Trip(
                $"trip_{start.Ticks}",
                $"Trip · {start:MMM yyyy}",
                start, end, avgLat, avgLon, items.Count);
        }
    }
}
