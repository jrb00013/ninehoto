import Foundation

final class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    func cancel() {
        workItem?.cancel()
    }
}

final class Throttler {
    private let interval: TimeInterval
    private var lastExecutionTime: Date?
    private let queue: DispatchQueue
    
    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    
    func throttle(action: @escaping () -> Void) {
        let now = Date()
        
        if let lastTime = lastExecutionTime {
            let elapsed = now.timeIntervalSince(lastTime)
            if elapsed < interval {
                return
            }
        }
        
        lastExecutionTime = now
        queue.async(execute: action)
    }
    
    func reset() {
        lastExecutionTime = nil
    }
}

final class RetryHandler {
    static func retry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        queue: DispatchQueue = .global(),
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(delay * Double(attempt) * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? RetryError.exhausted
    }
}

enum RetryError: Error {
    case exhausted
}

final class OperationQueue {
    private let queue = DispatchQueue(label: "com.ninehoto.operationqueue", qos: .userInitiated, attributes: .concurrent)
    private var operations: [UUID: DispatchWorkItem] = [:]
    private let lock = NSLock()
    
    func enqueue(_ operation: @escaping () -> Void, identifier: UUID) {
        let workItem = DispatchWorkItem(block: operation)
        
        lock.lock()
        operations[identifier] = workItem
        lock.unlock()
        
        queue.async(execute: workItem)
    }
    
    func cancel(identifier: UUID) {
        lock.lock()
        operations[identifier]?.cancel()
        operations.removeValue(forKey: identifier)
        lock.unlock()
    }
    
    func cancelAll() {
        lock.lock()
        operations.values.forEach { $0.cancel() }
        operations.removeAll()
        lock.unlock()
    }
}