using System;
using Android.Util;
using Ninehoto.Android.Interfaces;

namespace Ninehoto.Android.Services
{
    public class LoggingService : ILoggingService
    {
        private const string Tag = "Ninehoto";
        private LogLevel _minimumLevel = LogLevel.Debug;

        public enum LogLevel
        {
            Debug,
            Info,
            Warning,
            Error
        }

        public void Configure(LogLevel minimumLevel)
        {
            _minimumLevel = minimumLevel;
        }

        public void Debug(string message)
        {
            if (_minimumLevel <= LogLevel.Debug)
                Log.D(Tag, message);
        }

        public void Info(string message)
        {
            if (_minimumLevel <= LogLevel.Info)
                Log.I(Tag, message);
        }

        public void Warning(string message)
        {
            if (_minimumLevel <= LogLevel.Warning)
                Log.W(Tag, message);
        }

        public void Error(string message)
        {
            if (_minimumLevel <= LogLevel.Error)
                Log.E(Tag, message);
        }

        public void Error(Exception ex, string context = "")
        {
            var message = string.IsNullOrEmpty(context) 
                ? ex.ToString() 
                : $"{context}: {ex.Message}";
            Error(message);
        }
    }
}