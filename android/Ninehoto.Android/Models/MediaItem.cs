using System;

namespace Ninehoto.Android.Models
{
    public class MediaItem
    {
        public string Id { get; set; } = "";
        public MediaType MediaType { get; set; }
        public DateTime? CreationDate { get; set; }
        public int PixelWidth { get; set; }
        public int PixelHeight { get; set; }
        public double Duration { get; set; }
        public bool IsVideo { get; set; }

        public enum MediaType
        {
            Photo,
            Video,
            Unknown
        }

        public double AspectRatio => PixelHeight > 0 ? (double)PixelWidth / PixelHeight : 1;
        public bool IsPortrait => AspectRatio < 1;
        public bool IsLandscape => AspectRatio > 1;
        public bool IsSquare => Math.Abs(AspectRatio - 1) < 0.01;

        public string FormattedDuration
        {
            get
            {
                if (!IsVideo || Duration <= 0)
                    return "";
                
                var minutes = (int)Duration / 60;
                var seconds = (int)Duration % 60;
                return $"{minutes}:{seconds:D2}";
            }
        }
    }

    public class MediaRepository
    {
        private readonly IMediaService _mediaService;

        public MediaRepository(IMediaService mediaService)
        {
            _mediaService = mediaService;
        }

        public async System.Threading.Tasks.Task<MediaStoreResult> RequestPermissionAsync()
        {
            return await _mediaService.RequestPermissionAsync();
        }

        public async System.Threading.Tasks.Task<System.Collections.Generic.List<MediaItem>> FetchRecentMediaAsync(int limit)
        {
            return await _mediaService.FetchRecentMediaAsync(limit);
        }

        public async System.Threading.Tasks.Task<bool> DeleteMediaAsync(System.Collections.Generic.List<string> assetIds)
        {
            return await _mediaService.DeleteMediaAsync(assetIds);
        }
    }

    public class MediaStoreResult
    {
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }

        public static MediaStoreResult Ok() => new MediaStoreResult { Success = true };
        public static MediaStoreResult Fail(string message) => new MediaStoreResult { Success = false, ErrorMessage = message };
    }
}