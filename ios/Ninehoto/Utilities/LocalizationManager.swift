import Foundation

enum LocaleKey: String {
    // Main Menu
    case appTitle = "app_title"
    case startSession = "start_session"
    case settings = "settings"
    case statistics = "statistics"
    case about = "about"

    // Swipe Screen
    case swipeLeftToDelete = "swipe_left_to_delete"
    case swipeRightToKeep = "swipe_right_to_keep"
    case undo = "undo"
    case done = "done"
    case remaining = "remaining"
    case markedForDeletion = "marked_for_deletion"

    // Finish Confirmation
    case finishSession = "finish_session"
    case confirmDelete = "confirm_delete"
    case deleteCountMessage = "delete_count_message"
    case cancel = "cancel"
    case confirm = "confirm"

    // Results
    case successTitle = "success_title"
    case deletedMessage = "deleted_message"
    case keepMessage = "keep_message"

    // Permissions
    case photoLibraryAccessRequired = "photo_library_access_required"
    case openSettings = "open_settings"
    case accessDenied = "access_denied"

    // Errors
    case errorTitle = "error_title"
    case noPhotosFound = "no_photos_found"
    case deletionFailed = "deletion_failed"
    case genericError = "generic_error"

    // Settings
    case hapticFeedback = "haptic_feedback"
    case thumbnailQuality = "thumbnail_quality"
    case sortOrder = "sort_order"
    case resetStatistics = "reset_statistics"
    case clearCache = "clear_cache"
    case appVersion = "app_version"

    // Accessibility
    case photoCardAccessibility = "photo_card_accessibility"
    case videoCardAccessibility = "video_card_accessibility"
    case swipeLeftButtonAccessibility = "swipe_left_button_accessibility"
    case swipeRightButtonAccessibility = "swipe_right_button_accessibility"
    case undoButtonAccessibility = "undo_button_accessibility"
    case progressAccessibility = "progress_accessibility"

    // Quality Options
    case qualityLow = "quality_low"
    case qualityMedium = "quality_medium"
    case qualityHigh = "quality_high"

    // Sort Options
    case sortNewestFirst = "sort_newest_first"
    case sortOldestFirst = "sort_oldest_first"
    case sortRecentlyAdded = "sort_recently_added"

    // Storage Preview
    case fileSizeLabel = "file_size_label"
    case spaceFreedFormat = "space_freed_format"
    case deleteCountWithSize = "delete_count_with_size"
    case spaceSavedStat = "space_saved_stat"

    // Burst & Duplicate Grouping
    case burstLabel = "burst_label"
    case duplicateLabel = "duplicate_label"
    case burstGrouping = "burst_grouping"

    // Trip / Location Filtering
    case filterPhotos = "filter_photos"
    case filterByAlbum = "filter_by_album"
    case filterByTrip = "filter_by_trip"
    case allPhotos = "all_photos"
    case tripFiltering = "trip_filtering"
}

final class LocalizationManager {
    static let shared = LocalizationManager()

    private(set) var currentLocale: Locale = .current

    private var translations: [String: [LocaleKey: String]] = [:]

    private init() {
        loadTranslations()
    }

    private func loadTranslations() {
        translations["en"] = [
            .appTitle: "ninehoto",
            .startSession: "Start Session",
            .settings: "Settings",
            .statistics: "Statistics",
            .about: "About",
            .swipeLeftToDelete: "Swipe left to delete",
            .swipeRightToKeep: "Swipe right to keep",
            .undo: "Undo",
            .done: "Done",
            .remaining: "remaining",
            .markedForDeletion: "marked for deletion",
            .finishSession: "Finish Session",
            .confirmDelete: "Confirm Deletion",
            .deleteCountMessage: "You marked %d item(s) for deletion",
            .cancel: "Cancel",
            .confirm: "Delete",
            .successTitle: "Session Complete",
            .deletedMessage: "Deleted %d item(s)",
            .keepMessage: "Kept %d item(s)",
            .photoLibraryAccessRequired: "Photo library access is required",
            .openSettings: "Open Settings",
            .accessDenied: "Access denied",
            .errorTitle: "Error",
            .noPhotosFound: "No photos or videos found",
            .deletionFailed: "Some items could not be deleted",
            .genericError: "Something went wrong",
            .hapticFeedback: "Haptic Feedback",
            .thumbnailQuality: "Thumbnail Quality",
            .sortOrder: "Sort Order",
            .resetStatistics: "Reset Statistics",
            .clearCache: "Clear Cache",
            .appVersion: "App Version",
            .photoCardAccessibility: "Photo, %@",
            .videoCardAccessibility: "Video, %@, duration %@",
            .swipeLeftButtonAccessibility: "Swipe left to delete",
            .swipeRightButtonAccessibility: "Swipe right to keep",
            .undoButtonAccessibility: "Undo last swipe",
            .progressAccessibility: "Progress: %d of %d",
            .qualityLow: "Low (Fast)",
            .qualityMedium: "Medium",
            .qualityHigh: "High (Slow)",
            .sortNewestFirst: "Newest First",
            .sortOldestFirst: "Oldest First",
            .sortRecentlyAdded: "Recently Added",
            .fileSizeLabel: "%@",
            .spaceFreedFormat: "Free up %@",
            .deleteCountWithSize: "Delete %d items (%@)",
            .spaceSavedStat: "Space saved: %@",
            .burstLabel: "Burst · %d",
            .duplicateLabel: "%d duplicates",
            .burstGrouping: "Burst Grouping",
            .filterPhotos: "Filter Photos",
            .filterByAlbum: "Albums",
            .filterByTrip: "Trips",
            .allPhotos: "All photos (no filter)",
            .tripFiltering: "Trip Filtering"
        ]

        translations["es"] = [
            .appTitle: "ninehoto",
            .startSession: "Iniciar Sesión",
            .settings: "Configuración",
            .statistics: "Estadísticas",
            .about: "Acerca de",
            .swipeLeftToDelete: "Desliza a la izquierda para eliminar",
            .swipeRightToKeep: "Desliza a la derecha para conservar",
            .undo: "Deshacer",
            .done: "Hecho",
            .remaining: "restantes",
            .markedForDeletion: "marcados para eliminar",
            .finishSession: "Terminar Sesión",
            .confirmDelete: "Confirmar Eliminación",
            .deleteCountMessage: "Marcaste %d elemento(s) para eliminar",
            .cancel: "Cancelar",
            .confirm: "Eliminar",
            .successTitle: "Sesión Completada",
            .deletedMessage: "Eliminado(s) %d elemento(s)",
            .keepMessage: "Conservado(s) %d elemento(s)",
            .photoLibraryAccessRequired: "Se requiere acceso a la biblioteca de fotos",
            .openSettings: "Abrir Configuración",
            .accessDenied: "Acceso denegado",
            .errorTitle: "Error",
            .noPhotosFound: "No se encontraron fotos o videos",
            .deletionFailed: "Algunos elementos no pudieron eliminarse",
            .genericError: "Algo salió mal",
            .hapticFeedback: "Retroalimentación Háptica",
            .thumbnailQuality: "Calidad de Miniaturas",
            .sortOrder: "Orden de Clasificación",
            .resetStatistics: "Restablecer Estadísticas",
            .clearCache: "Limpiar Caché",
            .appVersion: "Versión de la App",
            .qualityLow: "Baja (Rápido)",
            .qualityMedium: "Media",
            .qualityHigh: "Alta (Lento)",
            .sortNewestFirst: "Más Reciente Primero",
            .sortOldestFirst: "Más Antiguo Primero",
            .sortRecentlyAdded: "Agregados Recientemente",
            .fileSizeLabel: "%@",
            .spaceFreedFormat: "Libera %@",
            .deleteCountWithSize: "Eliminar %d elementos (%@)",
            .spaceSavedStat: "Espacio liberado: %@",
            .burstLabel: "Ráfaga · %d",
            .duplicateLabel: "%d duplicados",
            .burstGrouping: "Agrupación de Ráfagas",
            .filterPhotos: "Filtrar Fotos",
            .filterByAlbum: "Álbumes",
            .filterByTrip: "Viajes",
            .allPhotos: "Todas las fotos (sin filtro)",
            .tripFiltering: "Filtro de Viajes"
        ]
    }

    func translate(_ key: LocaleKey, locale: String? = nil) -> String {
        let languageCode = locale ?? currentLocale.language.languageCode?.identifier ?? "en"
        return translations[languageCode]?[key] ?? translations["en"]?[key] ?? key.rawValue
    }

    func translate(_ key: LocaleKey, args: CVarArg..., locale: String? = nil) -> String {
        let template = translate(key, locale: locale)
        return String(format: template, args)
    }

    func setLocale(_ locale: Locale) {
        currentLocale = locale
    }

    var availableLocales: [String] {
        Array(translations.keys).sorted()
    }
}