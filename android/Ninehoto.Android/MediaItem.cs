using Android.Net;

namespace Ninehoto;

public sealed class MediaItem
{
    public MediaItem(long id, Uri contentUri, bool isVideo, long dateAddedSec)
    {
        Id = id;
        ContentUri = contentUri;
        IsVideo = isVideo;
        DateAddedSec = dateAddedSec;
    }

    public long Id { get; }
    public Uri ContentUri { get; }
    public bool IsVideo { get; }
    public long DateAddedSec { get; }
}
