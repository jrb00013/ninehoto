import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case photoLibraryAccessDenied
    case photoLibraryAccessRestricted
    case noPhotosFound
    case thumbnailLoadFailed(assetId: String)
    case deletionFailed(count: Int, reason: String)
    case sessionExpired
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .photoLibraryAccessDenied:
            return "Photo library access was denied. Please enable it in Settings."
        case .photoLibraryAccessRestricted:
            return "Photo library access is restricted on this device."
        case .noPhotosFound:
            return "No photos or videos were found in your library."
        case .thumbnailLoadFailed(let assetId):
            return "Failed to load thumbnail for asset: \(assetId)"
        case .deletionFailed(let count, let reason):
            return "Failed to delete \(count) item(s): \(reason)"
        case .sessionExpired:
            return "Your session has expired. Please start again."
        case .unknown(let underlying):
            return "An unexpected error occurred: \(underlying.localizedDescription)"
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .photoLibraryAccessDenied, .photoLibraryAccessRestricted:
            return true
        case .noPhotosFound:
            return true
        case .thumbnailLoadFailed:
            return true
        case .deletionFailed:
            return true
        case .sessionExpired:
            return true
        case .unknown:
            return true
        }
    }
}