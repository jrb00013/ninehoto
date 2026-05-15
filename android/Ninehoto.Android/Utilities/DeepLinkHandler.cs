using System;
using Android.Content;

namespace Ninehoto.Android.Utilities
{
    public enum DeepLink
    {
        Home,
        Settings,
        Statistics,
        About,
        SwipeSession,
        FinishConfirmation,
        Unknown
    }

    public class DeepLinkHandler
    {
        private static DeepLinkHandler? _instance;
        public static DeepLinkHandler Instance => _instance ??= new DeepLinkHandler();

        private readonly ILoggingService _logger;

        private DeepLinkHandler()
        {
            _logger = new LoggingService();
        }

        public DeepLink Parse(Android.Net.Uri uri)
        {
            if (uri == null || string.IsNullOrEmpty(uri.Host))
                return DeepLink.Unknown;

            return uri.Host.ToLowerInvariant() switch
            {
                "home" => DeepLink.Home,
                "settings" => DeepLink.Settings,
                "statistics" => DeepLink.Statistics,
                "about" => DeepLink.About,
                "session" => DeepLink.SwipeSession,
                "finish" => DeepLink.FinishConfirmation,
                _ => DeepLink.Unknown
            };
        }

        public bool Handle(Android.Net.Uri uri)
        {
            var deepLink = Parse(uri);

            if (deepLink == DeepLink.Unknown)
            {
                _logger.Warning($"Unknown deep link: {uri}");
                return false;
            }

            _logger.Info($"Handling deep link: {deepLink}");

            switch (deepLink)
            {
                case DeepLink.Settings:
                    NavigateToSettings();
                    return true;
                case DeepLink.Statistics:
                    NavigateToStatistics();
                    return true;
                case DeepLink.About:
                    NavigateToAbout();
                    return true;
                default:
                    return true;
            }
        }

        private void NavigateToSettings()
        {
            var intent = new Intent(Android.App.Application.Context, typeof(SettingsActivity));
            intent.AddFlags(ActivityFlags.NewTask);
            Android.App.Application.Context.StartActivity(intent);
        }

        private void NavigateToStatistics()
        {
            var intent = new Intent(Android.App.Application.Context, typeof(StatisticsActivity));
            intent.AddFlags(ActivityFlags.NewTask);
            Android.App.Application.Context.StartActivity(intent);
        }

        private void NavigateToAbout()
        {
            var intent = new Intent(Android.App.Application.Context, typeof(AboutActivity));
            intent.AddFlags(ActivityFlags.NewTask);
            Android.App.Application.Context.StartActivity(intent);
        }

        public string GetPath(DeepLink link)
        {
            return link switch
            {
                DeepLink.Home => "/",
                DeepLink.Settings => "/settings",
                DeepLink.Statistics => "/statistics",
                DeepLink.About => "/about",
                DeepLink.SwipeSession => "/session",
                DeepLink.FinishConfirmation => "/session/finish",
                DeepLink.Unknown => "",
                _ => ""
            };
        }
    }
}