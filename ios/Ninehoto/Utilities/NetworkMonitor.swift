import Foundation
import Network

enum ConnectionType {
    case wifi
    case cellular
    case wired
    case unknown
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.ninehoto.networkmonitor")
    private var isRunning = false

    private(set) var isConnected = true
    private(set) var connectionType: ConnectionType = .unknown

    var isOnWiFi: Bool { connectionType == .wifi }
    var isOnCellular: Bool { connectionType == .cellular }

    private init() {}

    func startMonitoring() {
        guard !isRunning else { return }
        isRunning = true
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.connectionType = .wired
            } else {
                self?.connectionType = .unknown
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        guard isRunning else { return }
        isRunning = false
        monitor.cancel()
    }
}
