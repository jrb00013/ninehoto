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
        try
        {
            if (Build.VERSION.SdkInt >= BuildVersionCodes.Q)
            {
                var size = new Size(ThumbnailMaxPx, ThumbnailMaxPx);
                return _resolver.LoadThumbnail(item.ContentUri, size, null);
            }

            using var stream = _resolver.OpenInputStream(item.ContentUri);
            if (stream == null)
            {
                return null;
            }

            return BitmapFactory.DecodeStream(stream);
        }
        catch
        {
            return null;
        }
    }
}
