using Android.Content;
using Android.Database;
using Android.Graphics;
using Android.OS;
using Android.Provider;
using Android.Util;
using Android.Net;
using Ninehoto.Android.Models;
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

    public List<AssetGroup> GroupAssets(IReadOnlyList<MediaItem> items)
    {
        var remaining = new HashSet<long>(items.Select(i => i.Id));
        var groups = new List<AssetGroup>();
        var itemMap = items.ToDictionary(i => i.Id);

        var burstGroups = items
            .Where(i => !string.IsNullOrEmpty(i.BurstId))
            .GroupBy(i => i.BurstId!)
            .Where(g => g.Count() > 1)
            .ToList();

        foreach (var bg in burstGroups)
        {
            var sorted = bg.OrderBy(i => i.DateAddedSec).ToList();
            groups.Add(new AssetGroup(sorted, GroupType.Burst));
            foreach (var item in sorted) remaining.Remove(item.Id);
        }

        var singles = remaining.Select(id => itemMap[id])
            .OrderBy(i => i.DateAddedSec)
            .ToList();

        var used = new HashSet<long>();

        foreach (var a in singles)
        {
            if (used.Contains(a.Id)) continue;
            var grp = new List<MediaItem> { a };
            used.Add(a.Id);

            foreach (var b in singles)
            {
                if (used.Contains(b.Id)) continue;
                if (AreDuplicates(a, b))
                {
                    grp.Add(b);
                    used.Add(b.Id);
                }
            }

            groups.Add(grp.Count > 1
                ? new AssetGroup(grp, GroupType.Duplicate)
                : new AssetGroup(grp, GroupType.Single));
        }

        return groups;
    }

    private static bool AreDuplicates(MediaItem a, MediaItem b)
    {
        long timeDelta = System.Math.Abs(a.DateAddedSec - b.DateAddedSec);
        if (timeDelta > 3) return false;

        if (!double.IsNaN(a.Latitude) && !double.IsNaN(b.Latitude))
        {
            double latDelta = System.Math.Abs(a.Latitude - b.Latitude);
            double lonDelta = System.Math.Abs(a.Longitude - b.Longitude);
            if (latDelta > 0.0001 || lonDelta > 0.0001) return false;
        }

        if (a.Width > 0 && b.Width > 0 && (a.Width != b.Width || a.Height != b.Height))
            return false;

        return true;
    }



    public Bitmap? LoadThumbnail(MediaItem item)
    {
        return _cache.Load(item.Id, item.ContentUri, ThumbnailMaxPx);
    }

    public void PrefetchFrom(int startIndex, IReadOnlyList<MediaItem> queue)
    {
        int end = System.Math.Min(startIndex + 5, queue.Count);
        for (int i = startIndex; i < end; i++)
        {
            var item = queue[i];
            if (_cache.Get(item.Id) == null)
            {
                _ = _cache.Load(item.Id, item.ContentUri, ThumbnailMaxPx);
            }
        }
    }

    public List<string> GetBucketNames()
    {
        var names = new List<string>();
        var projection = new[] { MediaStore.Images.Media.BucketDisplayName };
        using ICursor? cursor = _resolver.Query(
            MediaStore.Images.Media.ExternalContentUri!,
            projection, null, null, null);
        if (cursor == null) return names;

        int col = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.BucketDisplayName);
        while (cursor.MoveToNext())
        {
            var name = cursor.GetString(col);
            if (!string.IsNullOrEmpty(name) && !names.Contains(name))
                names.Add(name);
        }
        return names;
    }

    public IReadOnlyList<MediaItem> LoadMediaFromBucket(string bucketName)
    {
        var images = QueryCollection(MediaStore.Images.Media.ExternalContentUri!, isVideo: false,
            selection: $"{MediaStore.Images.Media.BucketDisplayName} = ?",
            selectionArgs: new[] { bucketName });
        var videos = QueryCollection(MediaStore.Video.Media.ExternalContentUri!, isVideo: true,
            selection: $"{MediaStore.Video.Media.BucketDisplayName} = ?",
            selectionArgs: new[] { bucketName });

        var combined = new List<MediaItem>(images.Count + videos.Count);
        combined.AddRange(images);
        combined.AddRange(videos);
        combined.Sort((a, b) => b.DateAddedSec.CompareTo(a.DateAddedSec));
        if (combined.Count > SessionLimit)
            combined.RemoveRange(SessionLimit, combined.Count - SessionLimit);
        return combined;
    }

    public void ClearCache() => _cache.Clear();

    private List<MediaItem> QueryCollection(Uri collection, bool isVideo,
        string? selection = null, string[]? selectionArgs = null)
    {
        var projection = new[]
        {
            MediaStore.MediaColumns.Id,
            MediaStore.MediaColumns.DateAdded,
            MediaStore.MediaColumns.Size,
            MediaStore.MediaColumns.Width,
            MediaStore.MediaColumns.Height,
        };

        var sort = $"{MediaStore.MediaColumns.DateAdded} DESC";

        var list = new List<MediaItem>();
        using ICursor? cursor = _resolver.Query(collection, projection, selection, selectionArgs, sort);
        if (cursor == null) return list;

        int idCol = cursor.GetColumnIndexOrThrow(MediaStore.MediaColumns.Id);
        int dateCol = cursor.GetColumnIndexOrThrow(MediaStore.MediaColumns.DateAdded);
        int sizeCol = cursor.GetColumnIndex(MediaStore.MediaColumns.Size);
        int widthCol = cursor.GetColumnIndex(MediaStore.MediaColumns.Width);
        int heightCol = cursor.GetColumnIndex(MediaStore.MediaColumns.Height);

        while (cursor.MoveToNext())
        {
            long id = cursor.GetLong(idCol);
            long dateAdded = cursor.GetLong(dateCol);
            long fileSize = sizeCol >= 0 ? cursor.GetLong(sizeCol) : 0;
            int width = widthCol >= 0 ? cursor.GetInt(widthCol) : 0;
            int height = heightCol >= 0 ? cursor.GetInt(heightCol) : 0;
            Uri uri = ContentUris.WithAppendedId(collection, id);
            list.Add(new MediaItem(id, uri, isVideo, dateAdded, fileSize, width, height));
        }

        return list;
    }
}
