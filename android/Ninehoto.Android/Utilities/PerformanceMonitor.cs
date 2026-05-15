using System;
using System.Collections.Generic;
using System.Diagnostics;
using Android.Util;

namespace Ninehoto.Android.Utilities
{
    public class PerformanceMonitor
    {
        private static PerformanceMonitor? _instance;
        public static PerformanceMonitor Instance => _instance ??= new PerformanceMonitor();

        private Dictionary<string, List<double>> _measurements = new Dictionary<string, List<double>>();
        private readonly object _lock = new object();

        private const string Tag = "PerformanceMonitor";

        public void Measure(Action action, string label)
        {
            var sw = new Stopwatch();
            sw.Start();
            action();
            sw.Stop();
            RecordMeasurement(label, sw.ElapsedMilliseconds);
        }

        public T Measure<T>(Func<T> func, string label)
        {
            var sw = new Stopwatch();
            sw.Start();
            var result = func();
            sw.Stop();
            RecordMeasurement(label, sw.ElapsedMilliseconds);
            return result;
        }

        public async System.Threading.Tasks.Task MeasureAsync(Func<System.Threading.Tasks.Task> task, string label)
        {
            var sw = new Stopwatch();
            sw.Start();
            await task();
            sw.Stop();
            RecordMeasurement(label, sw.ElapsedMilliseconds);
        }

        private void RecordMeasurement(string label, double durationMs)
        {
            lock (_lock)
            {
                if (!_measurements.ContainsKey(label))
                    _measurements[label] = new List<double>();

                _measurements[label].Add(durationMs);

                if (FeatureFlags.Instance.IsPerformanceMetricsEnabled)
                {
                    Log.Debug(Tag, $"[{label}] {durationMs:F2}ms");
                }
            }
        }

        public PerformanceStats? GetStatistics(string label)
        {
            lock (_lock)
            {
                if (!_measurements.ContainsKey(label) || _measurements[label].Count == 0)
                    return null;

                var measurements = _measurements[label];
                measurements.Sort();

                var count = measurements.Count;
                var sum = 0.0;
                foreach (var m in measurements)
                    sum += m;

                return new PerformanceStats
                {
                    Label = label,
                    Count = count,
                    AverageMs = sum / count,
                    MinMs = measurements[0],
                    MaxMs = measurements[count - 1],
                    MedianMs = measurements[count / 2],
                    TotalMs = sum
                };
            }
        }

        public List<PerformanceStats> GetAllStatistics()
        {
            var results = new List<PerformanceStats>();
            lock (_lock)
            {
                foreach (var label in _measurements.Keys)
                {
                    var stats = GetStatistics(label);
                    if (stats != null)
                        results.Add(stats);
                }
            }
            results.Sort((a, b) => b.AverageMs.CompareTo(a.AverageMs));
            return results;
        }

        public void Clear()
        {
            lock (_lock)
            {
                _measurements.Clear();
            }
        }

        public void PrintReport()
        {
            var stats = GetAllStatistics();
            Log.Info(Tag, "=== Performance Report ===");
            foreach (var stat in stats)
            {
                Log.Info(Tag, $"{stat.Label}:");
                Log.Info(Tag, $"  Count: {stat.Count}");
                Log.Info(Tag, $"  Avg: {stat.AverageMs:F2}ms");
                Log.Info(Tag, $"  Min: {stat.MinMs:F2}ms");
                Log.Info(Tag, $"  Max: {stat.MaxMs:F2}ms");
                Log.Info(Tag, $"  Median: {stat.MedianMs:F2}ms");
                Log.Info(Tag, "");
            }
        }
    }

    public class PerformanceStats
    {
        public string Label { get; set; } = "";
        public int Count { get; set; }
        public double AverageMs { get; set; }
        public double MinMs { get; set; }
        public double MaxMs { get; set; }
        public double MedianMs { get; set; }
        public double TotalMs { get; set; }

        public string Formatted => $@"
{Label}:
  Count: {Count}
  Avg: {AverageMs:F2}ms
  Min: {MinMs:F2}ms
  Max: {MaxMs:F2}ms
  Median: {MedianMs:F2}ms";
    }
}