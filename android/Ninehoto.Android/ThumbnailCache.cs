using Android.Content;
using Android.Graphics;
using Android.OS;
using Android.Provider;

namespace Ninehoto;

public sealed class ThumbnailCache(Context context) : Java.Lang.Object
{
    private static ThumbnailCache? _instance;
    public static ThumbnailCache Instance(Context context) => _instance ??= new ThumbnailCache(context);

    private readonly ContentResolver _resolver = context.ContentResolver!;
    private readonly LruCache<long, Bitmap> _cache = new(Math.Min(50, (int)(Runtime.GetRuntime().MaxMemory() / 1024 / 16)));

    public Bitmap? Get(long mediaId) => _cache.Get(mediaId);

    public void Put(long mediaId, Bitmap bitmap)
    {
        if (bitmap != null)
        {
            _cache.Put(mediaId, bitmap);
        }
    }

    public Bitmap? Load(long mediaId, Uri contentUri, int targetPx)
    {
        if (_cache.Get(mediaId) is { } cached)
        {
            return cached;
        }

        try
        {
            Bitmap? bmp;
            if (Build.VERSION.SdkInt >= BuildVersionCodes.Q)
            {
                bmp = _resolver.LoadThumbnail(contentUri, new Size(targetPx, targetPx), null);
            }
            else
            {
                using var stream = _resolver.OpenInputStream(contentUri);
                bmp = stream == null ? null : BitmapFactory.DecodeStream(stream);
            }

            if (bmp != null)
            {
                _cache.Put(mediaId, bmp);
            }
            return bmp;
        }
        catch
        {
            return null;
        }
    }

    public void Prefetch(IReadOnlyList<MediaItem> items, int targetPx)
    {
        for (int i = 0; i < Math.Min(5, items.Count); i++)
        {
            var item = items[i];
            if (_cache.Get(item.Id) == null)
            {
                _ = Load(item.Id, item.ContentUri, targetPx);
            }
        }
    }

    public void Clear() => _cache.EvictAll();
}
