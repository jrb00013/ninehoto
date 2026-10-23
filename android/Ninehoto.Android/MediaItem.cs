using Android.Net;

namespace Ninehoto;

public sealed class MediaItem
{
    public MediaItem(long id, Uri contentUri, bool isVideo, long dateAddedSec,
        long fileSize = 0, int width = 0, int height = 0,
        double latitude = double.NaN, double longitude = double.NaN,
        string? burstId = null)
    {
        Id = id;
        ContentUri = contentUri;
        IsVideo = isVideo;
        DateAddedSec = dateAddedSec;
        FileSize = fileSize;
        Width = width;
        Height = height;
        Latitude = latitude;
        Longitude = longitude;
        BurstId = burstId;
    }

    public long Id { get; }
    public Uri ContentUri { get; }
    public bool IsVideo { get; }
    public long DateAddedSec { get; }
    public long FileSize { get; }
    public int Width { get; }
    public int Height { get; }
    public double Latitude { get; }
    public double Longitude { get; }
    public string? BurstId { get; }

    public string FormattedFileSize
    {
        get
        {
            if (FileSize < 1024) return $"{FileSize} B";
            if (FileSize < 1024 * 1024) return $"{FileSize / 1024.0:F1} KB";
            if (FileSize < 1024L * 1024 * 1024) return $"{FileSize / (1024.0 * 1024):F1} MB";
            return $"{FileSize / (1024.0 * 1024 * 1024):F1} GB";
        }
    }
}
