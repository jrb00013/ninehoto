using System;

namespace Ninehoto.Android.Interfaces
{
    public interface IAnalyticsService
    {
        void TrackEvent(string eventName);
        void TrackSessionStart();
        void TrackSessionEnd(int swipeCount, int deleteCount, int keepCount);
        void TrackSwipe(string direction, int index);
        void TrackUndo();
    }

    public interface ICacheService
    {
        void Set<T>(T value, string key);
        T? Get<T>(string key);
        void Remove(string key);
        void Clear();
    }

    public interface IEnvironmentService
    {
        string CurrentEnvironment { get; }
        bool IsDevelopment { get; }
        bool IsProduction { get; }
        string BaseUrl { get; }
    }

    public interface ISystemMonitorService
    {
        DeviceInfo GetDeviceInfo();
        MemoryInfo GetMemoryInfo();
        StorageInfo GetStorageInfo();
        BatteryInfo GetBatteryInfo();
    }

    public interface INetworkMonitorService
    {
        bool IsConnected { get; }
        void StartMonitoring();
        void StopMonitoring();
    }
}