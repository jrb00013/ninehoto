import Foundation

protocol ObservableObjectCallback: AnyObject {
    associatedtype State
    var state: State { get set }
    func update(_ newState: State)
}

class ObservableProperty<T> {
    typealias Listener = (T) -> Void
    
    var value: T {
        didSet {
            listeners.forEach { $0(value) }
        }
    }
    
    private var listeners: [Listener] = []
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping Listener) {
        listeners.append(listener)
        listener(value)
    }
    
    func unbindAll() {
        listeners.removeAll()
    }
}

class ReadOnlyObservableProperty<T> {
    let value: T
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T) -> Void) {
        self.listener = listener
        listener(value)
    }
}

final class StateRelay<State> {
    private var listeners: [(State) -> Void] = []
    
    func accept(_ state: State) {
        listeners.forEach { $0(state) }
    }
    
    func subscribe(_ listener: @escaping (State) -> Void) {
        listeners.append(listener)
    }
}

final class EventBus {
    static let shared = EventBus()
    
    private var events: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.ninehoto.eventbus")
    
    private init() {}
    
    func publish<T>(_ event: Event<T>) {
        queue.async { [weak self] in
            self?.events[event.name] = event.data
        }
    }
    
    func subscribe<T>(to eventType: Event<T>.Type, handler: @escaping (T) -> Void) {
        // Event subscription logic
    }
}

struct Event<T> {
    let name: String
    let data: T
}