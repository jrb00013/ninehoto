using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Android.App;
using Android.Content;
using Android.Provider;
using Ninehoto.Android.Models;

namespace Ninehoto.Android.Services
{
    public class MediaService : IMediaService
    {
        private readonly ILoggingService _logger;
        
        public MediaService(ILoggingService logger)
        {
            _logger = logger;
        }

        public async Task<MediaStoreResult> RequestPermissionAsync()
        {
            return await Task.Run(() =>
            {
                try
                {
                    var readPermission = Android.Manifest.Permission.ReadExternalStorage;
                    var writePermission = Android.Manifest.Permission.WriteExternalStorage;

                    var context = Android.App.Application.Context;
                    var readGranted = context.CheckSelfPermission(readPermission) == Android.Content.PM.Permission.Granted;
                    var writeGranted = context.CheckSelfPermission(writePermission) == Android.Content.PM.Permission.Granted;

                    if (readGranted && writeGranted)
                    {
                        _logger.Info("Media permission granted");
                        return MediaStoreResult.Ok();
                    }
                    
                    _logger.Warning("Media permission not granted");
                    return MediaStoreResult.Fail("Permission not granted");
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "Failed to check permission");
                    return MediaStoreResult.Fail(ex.Message);
                }
            });
        }

        public async Task<List<MediaItem>> FetchRecentMediaAsync(int limit)
        {
            return await Task.Run(() =>
            {
                var items = new List<MediaItem>();

                try
                {
                    var projection = new string[]
                    {
                        MediaStore.Images.Media.Id,
                        MediaStore.Images.Media.DisplayName,
                        MediaStore.Images.Media.DateAdded,
                        MediaStore.Images.Media.Width,
                        MediaStore.Images.Media.Height,
                        MediaStore.Images.Media.MimeType
                    };

                    var selection = $"{MediaStore.Images.Media.DateAdded} >= ?";
                    var selectionArgs = new string[] { "0" };
                    var sortOrder = $"{MediaStore.Images.Media.DateAdded} DESC";

                    var context = Android.App.Application.Context;
                    var cursor = context.ContentResolver.Query(
                        MediaStore.Images.Media.ExternalContentUri,
                        projection,
                        selection,
                        selectionArgs,
                        sortOrder
                    );

                    if (cursor != null)
                    {
                        var idColumn = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.Id);
                        var dateColumn = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.DateAdded);
                        var widthColumn = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.Width);
                        var heightColumn = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.Height);
                        var mimeColumn = cursor.GetColumnIndexOrThrow(MediaStore.Images.Media.MimeType);

                        int count = 0;
                        while (cursor.MoveToNext() && count < limit)
                        {
                            var id = cursor.GetLong(idColumn);
                            var date = cursor.GetLong(dateColumn);
                            var width = cursor.GetInt(widthColumn);
                            var height = cursor.GetInt(heightColumn);
                            var mimeType = cursor.GetString(mimeColumn);

                            var isVideo = mimeType != null && mimeType.StartsWith("video/");

                            items.Add(new MediaItem
                            {
                                Id = id.ToString(),
                                MediaType = isVideo ? MediaItem.MediaType.Video : MediaItem.MediaType.Photo,
                                CreationDate = DateTimeOffset.FromUnixTimeSeconds(date).DateTime,
                                PixelWidth = width,
                                PixelHeight = height,
                                IsVideo = isVideo
                            });

                            count++;
                        }

                        cursor.Close();
                    }

                    _logger.Info($"Fetched {items.Count} media items");
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "Failed to fetch media");
                }

                return items;
            });
        }

        public async Task<bool> DeleteMediaAsync(List<string> assetIds)
        {
            return await Task.Run(() =>
            {
                try
                {
                    var context = Android.App.Application.Context;
                    var selection = $"{MediaStore.Images.Media.Id} IN ({string.Join(",", assetIds)})";
                    var deleted = context.ContentResolver.Delete(
                        MediaStore.Images.Media.ExternalContentUri,
                        selection,
                        null
                    );

                    _logger.Info($"Deleted {deleted} items");
                    return deleted > 0;
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "Failed to delete media");
                    return false;
                }
            });
        }

        public async Task<Android.Graphics.Bitmap?> GetThumbnailAsync(string assetId, int width, int height)
        {
            return await Task.Run(() =>
            {
                try
                {
                    var context = Android.App.Application.Context;
                    var uri = ContentUris.WithAppendedId(MediaStore.Images.Media.ExternalContentUri, long.Parse(assetId));
                    
                    var options = new Android.Graphics.BitmapFactory.Options
                    {
                        InJustDecodeBounds = true
                    };

                    var stream = context.ContentResolver.OpenInputStream(uri);
                    if (stream != null)
                    {
                        Android.Graphics.BitmapFactory.DecodeStream(stream, null, options);
                        stream.Close();

                        options.InSampleSize = 1;
                        options.InJustDecodeBounds = false;

                        stream = context.ContentResolver.OpenInputStream(uri);
                        if (stream != null)
                        {
                            var bitmap = Android.Graphics.BitmapFactory.DecodeStream(stream, null, options);
                            stream.Close();
                            return bitmap;
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "Failed to get thumbnail");
                }

                return null;
            });
        }
    }
}