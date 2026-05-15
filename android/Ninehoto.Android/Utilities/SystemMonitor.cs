using System;
using System.IO;
using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;

namespace Ninehoto.Android.Utilities
{
    public class SystemMonitor
    {
        private static SystemMonitor? _instance;
        public static SystemMonitor Instance => _instance ??= new SystemMonitor();

        private readonly ActivityManager? _activityManager;
        private readonly PowerManager? _powerManager;

        private SystemMonitor()
        {
            _activityManager = Application.Context.GetSystemService(Context.ActivityService) as ActivityManager;
            _powerManager = Application.Context.GetSystemService(Context.PowerService) as PowerManager;
        }

        public DeviceInfo GetDeviceInfo()
        {
            return new DeviceInfo
            {
                Model = Build.Model,
                Manufacturer = Build.Manufacturer,
                Brand = Build.Brand,
                AndroidVersion = Build.VERSION.Release,
                SDKVersion = Build.VERSION.SdkInt,
                Device = Build.Device,
                Product = Build.Product,
                Hardware = Build.Hardware
            };
        }

        public MemoryInfo GetMemoryInfo()
        {
            if (_activityManager == null)
                return new MemoryInfo();

            var memInfo = new ActivityManager.MemoryInfo();
            _activityManager.GetMemoryInfo(memInfo);

            return new MemoryInfo
            {
                TotalMemory = memInfo.TotalMem,
                AvailableMemory = memInfo.AvailMem,
                LowMemory = memInfo.LowMemory,
                Threshold = memInfo.Threshold
            };
        }

        public StorageInfo GetStorageInfo()
        {
            var path = Android.OS.Environment.DataDirectory;
            var stat = new StatFs(path.Path);

            return new StorageInfo
            {
                TotalSpace = stat.BlockCountLong * stat.BlockSizeLong,
                AvailableSpace = stat.AvailableBlocksLong * stat.BlockSizeLong,
                UsedSpace = (stat.BlockCountLong - stat.AvailableBlocksLong) * stat.BlockSizeLong
            };
        }

        public BatteryInfo GetBatteryInfo()
        {
            if (_powerManager == null)
                return new BatteryInfo();

            var batteryIntent = Application.Context.RegisterReceiver(null, new Android.Content.IntentFilter(Intent.ActionBatteryChanged));
            if (batteryIntent == null)
                return new BatteryInfo();

            int level = batteryIntent.GetIntExtra(Android.Os.BatteryManager.ExtraLevel, -1);
            int scale = batteryIntent.GetIntExtra(Android.Os.BatteryManager.ExtraScale, -1);
            int status = batteryIntent.GetIntExtra(Android.Os.BatteryManager.ExtraStatus, -1);
            int plugged = batteryIntent.GetIntExtra(Android.Os.BatteryManager.ExtraPlugged, -1);

            float batteryPct = level * 100.0f / scale;

            return new BatteryInfo
            {
                Level = (int)batteryPct,
                IsCharging = status == BatteryManager.StatusCharging,
                IsFull = status == BatteryManager.StatusFull,
                ChargingType = plugged switch
                {
                    BatteryManager.BatteryPluggedAc => "AC",
                    BatteryManager.BatteryPluggedUsb => "USB",
                    BatteryManager.BatteryPluggedWireless => "Wireless",
                    _ => "Not Charging"
                }
            };
        }

        public bool IsLowMemory()
        {
            var memInfo = GetMemoryInfo();
            return memInfo.LowMemory;
        }

        public long GetAvailableMemory()
        {
            return GetMemoryInfo().AvailableMemory;
        }

        public long GetAvailableStorage()
        {
            return GetStorageInfo().AvailableSpace;
        }
    }

    public class DeviceInfo
    {
        public string Model { get; set; } = "";
        public string Manufacturer { get; set; } = "";
        public string Brand { get; set; } = "";
        public string AndroidVersion { get; set; } = "";
        public int SDKVersion { get; set; }
        public string Device { get; set; } = "";
        public string Product { get; set; } = "";
        public string Hardware { get; set; } = "";

        public string FullName => $"{Manufacturer} {Model}";
    }

    public class MemoryInfo
    {
        public long TotalMemory { get; set; }
        public long AvailableMemory { get; set; }
        public bool LowMemory { get; set; }
        public long Threshold { get; set; }

        public long UsedMemory => TotalMemory - AvailableMemory;
        public double UsedPercentage => TotalMemory > 0 ? (double)UsedMemory / TotalMemory * 100 : 0;
    }

    public class StorageInfo
    {
        public long TotalSpace { get; set; }
        public long AvailableSpace { get; set; }
        public long UsedSpace { get; set; }

        public double UsedPercentage => TotalSpace > 0 ? (double)UsedSpace / TotalSpace * 100 : 0;
    }

    public class BatteryInfo
    {
        public int Level { get; set; }
        public bool IsCharging { get; set; }
        public bool IsFull { get; set; }
        public string ChargingType { get; set; } = "";
    }

    public class SystemMonitorReceiver : BroadcastReceiver
    {
        public override void OnReceive(Context context, Intent intent)
        {
            if (intent.Action == Intent.ActionMemoryLow)
            {
                var loggingService = new LoggingService();
                loggingService.Warning("System memory is low!");
            }
            else if (intent.Action == Intent.ActionBatteryLow)
            {
                var loggingService = new LoggingService();
                loggingService.Warning("Battery is low!");
            }
        }
    }
}