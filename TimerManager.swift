import Foundation
import Combine

enum TimerState {
    case idle
    case running
    case paused
}

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    private init() {}
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var selectedMinutes: Int = 25
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedRemainingSeconds: Int = 0
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start(minutes: Int) {
        // 既存のタイマーを停止
        stop()
        
        selectedMinutes = minutes
        remainingSeconds = minutes * 60
        state = .running
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // バックグラウンドでも動作するようにRunLoopに追加
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func pause() {
        guard state == .running else { return }
        
        timer?.invalidate()
        timer = nil
        pausedRemainingSeconds = remainingSeconds
        state = .paused
    }
    
    func resume() {
        guard state == .paused else { return }
        
        remainingSeconds = pausedRemainingSeconds
        state = .running
        startTime = Date().addingTimeInterval(-Double((selectedMinutes * 60) - remainingSeconds))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        state = .idle
        remainingSeconds = 0
        pausedRemainingSeconds = 0
        startTime = nil
    }
    
    func snooze() {
        // 10分を追加して再スタート
        let additionalMinutes = 10
        let totalSeconds = remainingSeconds + (additionalMinutes * 60)
        
        // 既存のタイマーを停止
        stop()
        
        // 追加時間を含めて開始
        remainingSeconds = totalSeconds
        selectedMinutes = totalSeconds / 60
        state = .running
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // バックグラウンドでも動作するようにRunLoopに追加
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func tick() {
        guard state == .running else { return }
        
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            timerFinished()
        }
    }
    
    private func timerFinished() {
        timer?.invalidate()
        timer = nil
        state = .idle
        
        // タイマー終了を通知
        NotificationCenter.default.post(name: .timerFinished, object: nil)
    }
}

extension Notification.Name {
    static let timerFinished = Notification.Name("timerFinished")
}

