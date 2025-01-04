import Foundation
import Combine

class LEDTimerService {
    static let shared = LEDTimerService()
    
    private let timer: Timer.TimerPublisher
    private var cancellable: Cancellable?
    private var subscribers: Set<AnyHashable> = []
    
    @MainActor private(set) var currentTick: Int = 0
    
    private init() {
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
        setupTimer()
    }
    
    private func setupTimer() {
        cancellable = timer.connect()
    }
    
    func subscribe(_ id: AnyHashable) {
        subscribers.insert(id)
        
        // Start timer if this is the first subscriber
        if subscribers.count == 1 {
            cancellable = timer.connect()
        }
    }
    
    func unsubscribe(_ id: AnyHashable) {
        subscribers.remove(id)
        
        // Stop timer if no more subscribers
        if subscribers.isEmpty {
            cancellable?.cancel()
        }
    }
}
