import Foundation

final class AnimationQueue {
    static let shared = AnimationQueue()
    
    private var animations: [UUID: AnimationContext] = [:]
    private let queue = DispatchQueue(label: "com.ninehoto.animationqueue")
    
    private init() {}
    
    struct AnimationContext {
        let id: UUID
        let type: AnimationType
        let duration: TimeInterval
        let completion: (() -> Void)?
    }
    
    enum AnimationType {
        case fade
        case slide
        case scale
        case rotate
        case custom
    }
    
    @discardableResult
    func enqueue(type: AnimationType, duration: TimeInterval, completion: (() -> Void)? = nil) -> UUID {
        let id = UUID()
        let context = AnimationContext(id: id, type: type, duration: duration, completion: completion)
        
        queue.async { [weak self] in
            self?.animations[id] = context
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.complete(id)
        }
        
        return id
    }
    
    func cancel(_ id: UUID) {
        queue.async { [weak self] in
            self?.animations.removeValue(forKey: id)
        }
    }
    
    private func complete(_ id: UUID) {
        queue.async { [weak self] in
            if let context = self?.animations.removeValue(forKey: id) {
                DispatchQueue.main.async {
                    context.completion?()
                }
            }
        }
    }
    
    func clear() {
        queue.async { [weak self] in
            self?.animations.removeAll()
        }
    }
}