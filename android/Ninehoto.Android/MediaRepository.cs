using Android.Content;
using Android.Database;
using Android.Graphics;
using Android.OS;
using Android.Provider;
using Android.Util;
using Android.Net;
using Uri = Android.Net.Uri;

namespace Ninehoto;

public sealed class MediaRepository(Context context)
{
    private const int ThumbnailMaxPx = 1080;
    public const int SessionLimit = 200;

    private readonly ContentResolver _resolver = context.ContentResolver!;
    private readonly ThumbnailCache _cache = ThumbnailCache.Instance(context);

    public IReadOnlyList<MediaItem> LoadRecentMedia()
    {
        var images = QueryCollection(MediaStore.Images.Media.ExternalContentUri!, isVideo: false);
        var videos = QueryCollection(MediaStore.Video.Media.ExternalContentUri!, isVideo: true);

        var combined = new List<MediaItem>(images.Count + videos.Count);
        combined.AddRange(images);
        combined.AddRange(videos);
        combined.Sort((a, b) => b.DateAddedSec.CompareTo(a.DateAddedSec));
        if (combined.Count > SessionLimit)
        {
            combined.RemoveRange(SessionLimit, combined.Count - SessionLimit);
        }

        return combined;
    }

    private List<MediaItem> QueryCollection(Uri collection, bool isVideo)
    {
        var projection = new[]
        {
            MediaStore.MediaColumns.Id,
            MediaStore.MediaColumns.DateAdded,
        };

        var sort = $"{MediaStore.MediaColumns.DateAdded} DESC";

        var list = new List<MediaItem>();
        using ICursor? cursor = _resolver.Query(collection, projection, null, null, sort);
        if (cursor == null)
        {
            return list;
        }

        int idCol = cursor.GetColumnIndexOrThrow(MediaStore.MediaColumns.Id);
        int dateCol = cursor.GetColumnIndexOrThrow(MediaStore.MediaColumns.DateAdded);

        while (cursor.MoveToNext())
        {
            long id = cursor.GetLong(idCol);
            long dateAdded = cursor.GetLong(dateCol);
            Uri uri = ContentUris.WithAppendedId(collection, id);
            list.Add(new MediaItem(id, uri, isVideo, dateAdded));
        }

        return list;
    }

    public Bitmap? LoadThumbnail(MediaItem item)
    {
        return _cache.Load(item.Id, item.ContentUri, ThumbnailMaxPx);
    }

    public void PrefetchFrom(int startIndex, IReadOnlyList<MediaItem> queue)
    {
        int end = Math.Min(startIndex + 5, queue.Count);
        for (int i = startIndex; i < end; i++)
        {
            var item = queue[i];
            if (_cache.Get(item.Id) == null)
            {
                _ = _cache.Load(item.Id, item.ContentUri, ThumbnailMaxPx);
            }
        }
    }

    public void ClearCache() => _cache.Clear();
}
