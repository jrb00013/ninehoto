using System;
using System.Globalization;

namespace Ninehoto.Android.Utilities
{
    public class DateFormatters
    {
        private static DateFormatters? _instance;
        public static DateFormatters Instance => _instance ??= new DateFormatters();

        private readonly Java.Text.DateFormat _dateFormatter;
        private readonly Java.Text.DateFormat _shortDateFormatter;
        private readonly Java.Text.DateFormat _timeFormatter;

        private DateFormatters()
        {
            _dateFormatter = Java.Text.DateFormat.GetDateTimeInstance(Java.Text.DateFormat.Medium, Java.Text.DateFormat.Short, CultureInfo.CurrentCulture);
            _shortDateFormatter = Java.Text.DateFormat.GetDateInstance(Java.Text.DateFormat.Short, CultureInfo.CurrentCulture);
            _timeFormatter = Java.Text.DateFormat.GetTimeInstance(Java.Text.DateFormat.Short, CultureInfo.CurrentCulture);
        }

        public string Format(DateTime date)
        {
            return _dateFormatter.Format(date);
        }

        public string FormatShort(DateTime date)
        {
            return _shortDateFormatter.Format(date);
        }

        public string FormatTime(DateTime date)
        {
            return _timeFormatter.Format(date);
        }

        public string TimeAgo(DateTime date)
        {
            var diff = DateTime.Now - date;

            if (diff.TotalDays >= 365)
            {
                var years = (int)(diff.TotalDays / 365);
                return years == 1 ? "1 year ago" : $"{years} years ago";
            }
            if (diff.TotalDays >= 30)
            {
                var months = (int)(diff.TotalDays / 30);
                return months == 1 ? "1 month ago" : $"{months} months ago";
            }
            if (diff.TotalDays >= 7)
            {
                var weeks = (int)(diff.TotalDays / 7);
                return weeks == 1 ? "1 week ago" : $"{weeks} weeks ago";
            }
            if (diff.TotalDays >= 1)
            {
                var days = (int)diff.TotalDays;
                return days == 1 ? "Yesterday" : $"{days} days ago";
            }
            if (diff.TotalHours >= 1)
            {
                var hours = (int)diff.TotalHours;
                return hours == 1 ? "1 hour ago" : $"{hours} hours ago";
            }
            if (diff.TotalMinutes >= 1)
            {
                var minutes = (int)diff.TotalMinutes;
                return minutes == 1 ? "1 minute ago" : $"{minutes} minutes ago";
            }

            return "Just now";
        }

        public DateTime? Parse(string dateString)
        {
            try
            {
                return _dateFormatter.Parse(dateString);
            }
            catch
            {
                return null;
            }
        }

        public DateTime? ParseISO8601(string dateString)
        {
            try
            {
                return System.DateTime.Parse(dateString, null, System.Globalization.DateTimeStyles.RoundtripKind);
            }
            catch
            {
                return null;
            }
        }

        public string FormatISO8601(DateTime date)
        {
            return date.ToString("o", CultureInfo.InvariantCulture);
        }
    }

    public static class DateExtensions
    {
        public static string Formatted(this DateTime date) => DateFormatters.Instance.Format(date);
        public static string FormattedShort(this DateTime date) => DateFormatters.Instance.FormatShort(date);
        public static string FormattedTime(this DateTime date) => DateFormatters.Instance.FormatTime(date);
        public static string TimeAgo(this DateTime date) => DateFormatters.Instance.TimeAgo(date);
    }
}