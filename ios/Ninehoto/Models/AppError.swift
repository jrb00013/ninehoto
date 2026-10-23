import Foundation

enum AppErrorType: String {
    case photoLibraryAccessDenied
    case photoLibraryAccessRestricted
    case noPhotosFound
    case thumbnailLoadFailed
    case deletionFailed
    case sessionExpired
    case unknown
}

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

    var errorType: AppErrorType {
        switch self {
        case .photoLibraryAccessDenied: return .photoLibraryAccessDenied
        case .photoLibraryAccessRestricted: return .photoLibraryAccessRestricted
        case .noPhotosFound: return .noPhotosFound
        case .thumbnailLoadFailed: return .thumbnailLoadFailed
        case .deletionFailed: return .deletionFailed
        case .sessionExpired: return .sessionExpired
        case .unknown: return .unknown
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

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.photoLibraryAccessDenied, .photoLibraryAccessDenied),
             (.photoLibraryAccessRestricted, .photoLibraryAccessRestricted),
             (.noPhotosFound, .noPhotosFound),
             (.sessionExpired, .sessionExpired):
            return true
        case let (.thumbnailLoadFailed(a), .thumbnailLoadFailed(b)):
            return a == b
        case let (.deletionFailed(c1, r1), .deletionFailed(c2, r2)):
            return c1 == c2 && r1 == r2
        case let (.unknown(a), .unknown(b)):
            return a.localizedDescription == b.localizedDescription
        default:
            return false
        }
    }
}
