import Foundation

final class ServiceLocator {
    static let shared = ServiceLocator()

    private var services: [String: Any] = [:]
    private let lock = NSLock()

    private init() {}

    func register<T>(_ instance: T, for type: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        services[String(describing: type)] = instance
    }

    func registerLazy<T>(_ factory: @escaping () -> T, for type: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        services[String(describing: type)] = LazyBox(factory: factory)
    }

    func resolve<T>(_ type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)

        if let instance = services[key] as? T {
            return instance
        }

        if let lazyBox = services[key] as? LazyBox<T> {
            let instance = lazyBox.instance
            services[key] = instance
            return instance
        }

        return nil
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        services.removeAll()
    }
}

private final class LazyBox<T> {
    let factory: () -> T

    init(factory: @escaping () -> T) {
        self.factory = factory
    }

    lazy var instance: T = {
        factory()
    }()
}

extension ServiceLocator {
    func registerDefaults() {
        register(PhotoLibraryService(), for: PhotoLibraryServiceProtocol.self)
        register(ThumbnailCache.shared, for: ThumbnailCacheProtocol.self)
    }
}