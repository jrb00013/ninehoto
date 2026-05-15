using System;

namespace Ninehoto.Android.Models
{
    public enum AppErrorType
    {
        PhotoLibraryAccessDenied,
        PhotoLibraryAccessRestricted,
        NoPhotosFound,
        ThumbnailLoadFailed,
        DeletionFailed,
        SessionExpired,
        Unknown
    }

    public class AppError : Exception
    {
        public AppErrorType ErrorType { get; }
        public bool IsRecoverable { get; }
        public string? Context { get; }

        public AppError(AppErrorType errorType, string message, bool isRecoverable = true, string? context = null) 
            : base(message)
        {
            ErrorType = errorType;
            IsRecoverable = isRecoverable;
            Context = context;
        }

        public static AppError PhotoLibraryAccessDenied => 
            new AppError(AppErrorType.PhotoLibraryAccessDenied, 
                "Photo library access was denied. Please enable it in Settings.");

        public static AppError PhotoLibraryAccessRestricted => 
            new AppError(AppErrorType.PhotoLibraryAccessRestricted, 
                "Photo library access is restricted on this device.");

        public static AppError NoPhotosFound => 
            new AppError(AppErrorType.NoPhotosFound, 
                "No photos or videos were found in your library.");

        public static AppError ThumbnailLoadFailed(string assetId) => 
            new AppError(AppErrorType.ThumbnailLoadFailed, 
                $"Failed to load thumbnail for asset: {assetId}");

        public static AppError DeletionFailed(int count, string reason) => 
            new AppError(AppErrorType.DeletionFailed, 
                $"Failed to delete {count} item(s): {reason}");

        public static AppError SessionExpired => 
            new AppError(AppErrorType.SessionExpired, 
                "Your session has expired. Please start again.");

        public static AppError FromException(Exception ex) => 
            new AppError(AppErrorType.Unknown, ex.Message, true);
    }
}