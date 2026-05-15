using System;
using System.Collections.Generic;
using Android.Runtime;

namespace Ninehoto.Android.Utilities
{
    public class CacheManager
    {
        private static CacheManager? _instance;
        public static CacheManager Instance => _instance ??= new CacheManager();

        private readonly Android.Util.LruCache<string, Java.Lang.Object> _memoryCache;
        private readonly Android.Content.ISharedPreferences _prefs;
        private const string DiskCachePrefix = "cache_disk_";

        private CacheManager()
        {
            var maxMemory = (int)(Android.Runtime.Runtime.GetRuntime().MaxMemory() / 1024);
            var cacheSize = maxMemory / 8;

            _memoryCache = new Android.Util.LruCache<string, Java.Lang.Object>(cacheSize);
            _prefs = Android.App.Application.Context.GetSharedPreferences("ninehoto_cache", Android.Content.FileCreationMode.Private);
        }

        public void Set<T>(T value, string key) where T : Java.Lang.Object
        {
            _memoryCache.Put(key, value);
        }

        public T? Get<T>(string key) where T : Java.Lang.Object
        {
            return _memoryCache.Get(key) as T;
        }

        public void Remove(string key)
        {
            _memoryCache.Remove(key);
        }

        public void ClearMemoryCache()
        {
            _memoryCache.EvictAll();
        }

        public void SetToDisk<T>(T value, string key)
        {
            var json = Newtonsoft.Json.JsonConvert.SerializeObject(value);
            _prefs.Edit().PutString(DiskCachePrefix + key, json).Apply();
        }

        public T? GetFromDisk<T>(string key)
        {
            var json = _prefs.GetString(DiskCachePrefix + key, null);
            if (string.IsNullOrEmpty(json))
                return default;

            try
            {
                return Newtonsoft.Json.JsonConvert.DeserializeObject<T>(json);
            }
            catch
            {
                return default;
            }
        }

        public void RemoveFromDisk(string key)
        {
            _prefs.Edit().Remove(DiskCachePrefix + key).Apply();
        }

        public void ClearDiskCache()
        {
            var editor = _prefs.Edit();
            var keys = new List<string>();

            foreach (var key in _prefs.All.Keys)
            {
                if (key.StartsWith(DiskCachePrefix))
                    keys.Add(key);
            }

            foreach (var key in keys)
                editor.Remove(key);

            editor.Apply();
        }

        public void ClearAll()
        {
            ClearMemoryCache();
            ClearDiskCache();
        }

        public int GetMemoryCacheSize()
        {
            return _memoryCache.Size();
        }

        public int GetDiskCacheSize()
        {
            int size = 0;
            foreach (var key in _prefs.All.Keys)
            {
                if (key.StartsWith(DiskCachePrefix))
                {
                    var value = _prefs.All[key] as string;
                    if (value != null)
                        size += value.Length;
                }
            }
            return size;
        }
    }

    public class CachedValue<T>
    {
        public T Value { get; set; }
        public long Timestamp { get; set; }
        public long? ExpiresAt { get; set; }

        public CachedValue(T value, long? ttlSeconds = null)
        {
            Value = value;
            Timestamp = Java.System.CurrentTimeMillis();
            ExpiresAt = ttlSeconds.HasValue ? Timestamp + (ttlSeconds.Value * 1000) : (long?)null;
        }

        public bool IsExpired => ExpiresAt.HasValue && Java.System.CurrentTimeMillis() > ExpiresAt.Value;
    }

    public static class CacheManagerExtensions
    {
        public static void Cached<T>(this CacheManager manager, T value, string key, long? ttlSeconds = null)
        {
            var cached = new CachedValue<T>(value, ttlSeconds);
            manager.SetToDisk(cached, key);
        }

        public static T? GetCached<T>(this CacheManager manager, string key)
        {
            var cached = manager.GetFromDisk<CachedValue<T>>(key);
            if (cached == null)
                return default;

            if (cached.IsExpired)
            {
                manager.RemoveFromDisk(key);
                return default;
            }

            return cached.Value;
        }
    }
}