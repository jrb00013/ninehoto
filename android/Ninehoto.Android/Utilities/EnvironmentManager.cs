using System;

namespace Ninehoto.Android.Utilities
{
    public enum Environment
    {
        Development,
        Staging,
        Production
    }

    public class EnvironmentManager
    {
        private static EnvironmentManager? _instance;
        public static EnvironmentManager Instance => _instance ??= new EnvironmentManager();

        private readonly Android.Content.ISharedPreferences _prefs;
        private const string KeyEnvironment = "app_environment";

        private EnvironmentManager()
        {
            _prefs = Android.App.Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private);
        }

        public Environment Current
        {
            get
            {
                var rawValue = _prefs.GetString(KeyEnvironment, null);
                if (string.IsNullOrEmpty(rawValue))
                    return Environment.Development;

                return Enum.TryParse<Environment>(rawValue, true, out var result) 
                    ? result 
                    : Environment.Development;
            }
            set
            {
                _prefs.Edit().PutString(KeyEnvironment, value.ToString()).Apply();
                ConfigureEnvironment(value);
            }
        }

        private void ConfigureEnvironment(Environment env)
        {
            var loggingService = new LoggingService();

            switch (env)
            {
                case Environment.Development:
                    loggingService.Configure(LoggingService.LogLevel.Debug);
                    break;
                case Environment.Staging:
                    loggingService.Configure(LoggingService.LogLevel.Info);
                    break;
                case Environment.Production:
                    loggingService.Configure(LoggingService.LogLevel.Warning);
                    break;
            }

            if (FeatureFlags.Instance.IsDebugLoggingEnabled)
            {
                loggingService.Configure(LoggingService.LogLevel.Debug);
            }

            loggingService.Info($"Environment set to: {env}");
        }

        public bool IsDevelopment => Current == Environment.Development;
        public bool IsStaging => Current == Environment.Staging;
        public bool IsProduction => Current == Environment.Production;

        public string BaseUrl => Current switch
        {
            Environment.Development => "https://dev.ninehoto.com",
            Environment.Staging => "https://staging.ninehoto.com",
            Environment.Production => "https://ninehoto.com",
            _ => "https://ninehoto.com"
        };

        public bool IsDebugEnabled => Current != Environment.Production;

        public bool SupportsAnalytics => Current == Environment.Production;

        public void Initialize(Android.Content.Intent? launchIntent)
        {
#if DEBUG
            Current = Environment.Development;
#else
            if (launchIntent != null && launchIntent.HasExtra("ENVIRONMENT"))
            {
                var envString = launchIntent.GetStringExtra("ENVIRONMENT");
                if (!string.IsNullOrEmpty(envString) && Enum.TryParse<Environment>(envString, true, out var env))
                {
                    Current = env;
                    return;
                }
            }
            Current = Environment.Production;
#endif
        }
    }
}