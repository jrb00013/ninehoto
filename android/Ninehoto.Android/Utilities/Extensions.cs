using System;
using System.Linq;
using Android.Text;

namespace Ninehoto.Android.Utilities
{
    public static class StringExtensions
    {
        public static string Localized(this string key) => key;

        public static string Localized(this string key, params object[] args)
        {
            return string.Format(key, args);
        }

        public static bool IsValidEmail(this string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;
            
            return Android.Text.Patterns.EmailAddress.matcher(email).Matches();
        }

        public static bool IsValidUrl(this string url)
        {
            if (string.IsNullOrWhiteSpace(url))
                return false;
            
            return Android.Uri.UriMatcher.Match(url) != -1 || url.StartsWith("http");
        }

        public static string Truncated(this string text, int maxLength, string trailing = "...")
        {
            if (string.IsNullOrEmpty(text))
                return text;
            
            if (text.Length <= maxLength)
                return text;
            
            return text.Substring(0, maxLength - trailing.Length) + trailing;
        }

        public static string Trimmed(this string text)
        {
            return text?.Trim() ?? "";
        }

        public static string NilIfEmpty(this string text)
        {
            return string.IsNullOrEmpty(text) ? null : text;
        }

        public static bool IsNullOrEmpty(this string text)
        {
            return string.IsNullOrEmpty(text);
        }
    }

    public static class DateExtensions
    {
        public static DateTime StartOfDay(this DateTime date)
        {
            return date.Date;
        }

        public static DateTime EndOfDay(this DateTime date)
        {
            return date.Date.AddDays(1).AddTicks(-1);
        }

        public static bool IsSameDay(this DateTime date, DateTime otherDate)
        {
            return date.Year == otherDate.Year && 
                   date.Month == otherDate.Month && 
                   date.Day == otherDate.Day;
        }
    }

    public static class TimeSpanExtensions
    {
        public static string Formatted(this TimeSpan timeSpan)
        {
            if (timeSpan.TotalHours >= 1)
            {
                return $"{(int)timeSpan.TotalHours}:{timeSpan.Minutes:D2}:{timeSpan.Seconds:D2}";
            }
            return $"{timeSpan.Minutes}:{timeSpan.Seconds:D2}";
        }
    }

    public static class ArrayExtensions
    {
        public static T[] Uniqued<T>(this T[] array)
        {
            return array.Distinct().ToArray();
        }

        public static T? ElementAtOrDefault<T>(this T[] array, int index)
        {
            if (index < 0 || index >= array.Length)
                return default;
            return array[index];
        }
    }

    public static class CollectionExtensions
    {
        public static bool IsNotEmpty<T>(this System.Collections.Generic.ICollection<T> collection)
        {
            return collection.Count > 0;
        }

        public static T? FirstOrDefault<T>(this System.Collections.Generic.IEnumerable<T> enumerable)
        {
            foreach (var item in enumerable)
                return item;
            return default;
        }
    }
}