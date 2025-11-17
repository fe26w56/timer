import Foundation
import Combine

enum TimerState {
    case idle
    case running
    case paused
    case shortBreak
    case longBreak
}

enum TimerMode {
    case normal
    case pomodoro
}

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    private init() {
        loadSessionData()
        checkAndResetDailySession()
        loadPomodoroSettings()
    }
    
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var selectedMinutes: Int = 25
    @Published var mode: TimerMode = .normal
    @Published var todaySessionCount: Int = 0
    @Published var totalSessionCount: Int = 0
    
    // ポモドーロ設定
    @Published var pomodoroWorkMinutes: Int = 25
    @Published var pomodoroShortBreakMinutes: Int = 5
    @Published var pomodoroLongBreakMinutes: Int = 15
    @Published var sessionsUntilLongBreak: Int = 4
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedRemainingSeconds: Int = 0
    private var pausedState: TimerState? // 一時停止前の状態を保存
    private var currentSessionCount: Int = 0 // 現在のサイクルでのセッション数
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isPomodoroMode: Bool {
        return mode == .pomodoro
    }
    
    var currentStateDescription: String {
        switch state {
        case .idle:
            return "待機中"
        case .running:
            return "作業中"
        case .paused:
            return "一時停止中"
        case .shortBreak:
            return "短い休憩中"
        case .longBreak:
            return "長い休憩中"
        }
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
    
    func startPomodoro() {
        // 既存のタイマーを停止
        stop()
        
        mode = .pomodoro
        startWorkSession()
    }
    
    private func startWorkSession() {
        selectedMinutes = pomodoroWorkMinutes
        remainingSeconds = pomodoroWorkMinutes * 60
        state = .running
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startShortBreak() {
        selectedMinutes = pomodoroShortBreakMinutes
        remainingSeconds = pomodoroShortBreakMinutes * 60
        state = .shortBreak
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func startLongBreak() {
        selectedMinutes = pomodoroLongBreakMinutes
        remainingSeconds = pomodoroLongBreakMinutes * 60
        state = .longBreak
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func pause() {
        guard state == .running || state == .shortBreak || state == .longBreak else { return }
        
        timer?.invalidate()
        timer = nil
        pausedRemainingSeconds = remainingSeconds
        pausedState = state // 元の状態を保存
        state = .paused
    }
    
    func resume() {
        guard state == .paused, let previousState = pausedState else { return }
        
        remainingSeconds = pausedRemainingSeconds
        state = previousState // 保存された状態を復元
        pausedState = nil
        
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
        pausedState = nil
        startTime = nil
        
        // ポモドーロモードを停止する場合はリセット
        if mode == .pomodoro {
            mode = .normal
            currentSessionCount = 0
        }
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
        guard state == .running || state == .shortBreak || state == .longBreak else { return }
        
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            timerFinished()
        }
    }
    
    private func timerFinished() {
        timer?.invalidate()
        timer = nil
        
        if mode == .pomodoro {
            handlePomodoroCycleCompletion()
        } else {
            state = .idle
            // タイマー終了を通知
            NotificationCenter.default.post(name: .timerFinished, object: nil)
        }
    }
    
    private func handlePomodoroCycleCompletion() {
        switch state {
        case .running:
            // 作業時間終了 → セッション数をインクリメント
            currentSessionCount += 1
            todaySessionCount += 1
            totalSessionCount += 1
            saveSessionData()
            
            // 4セッション完了したら長い休憩、それ以外は短い休憩
            if currentSessionCount >= sessionsUntilLongBreak {
                // 長い休憩を開始
                currentSessionCount = 0
                startLongBreak()
                NotificationCenter.default.post(name: .pomodoroWorkFinished, object: nil, userInfo: ["isLongBreak": true])
            } else {
                // 短い休憩を開始
                startShortBreak()
                NotificationCenter.default.post(name: .pomodoroWorkFinished, object: nil, userInfo: ["isLongBreak": false])
            }
            
        case .shortBreak:
            // 短い休憩終了 → 作業時間を開始
            startWorkSession()
            NotificationCenter.default.post(name: .pomodoroBreakFinished, object: nil)
            
        case .longBreak:
            // 長い休憩終了 → 作業時間を開始（セッション数はリセット済み）
            startWorkSession()
            NotificationCenter.default.post(name: .pomodoroBreakFinished, object: nil)
            
        default:
            state = .idle
        }
    }
    
    // UserDefaultsでのデータ保存・読み込み
    private func saveSessionData() {
        let defaults = UserDefaults.standard
        defaults.set(todaySessionCount, forKey: "todaySessionCount")
        defaults.set(totalSessionCount, forKey: "totalSessionCount")
        defaults.set(Date(), forKey: "lastSessionDate")
    }
    
    private func loadSessionData() {
        let defaults = UserDefaults.standard
        todaySessionCount = defaults.integer(forKey: "todaySessionCount")
        totalSessionCount = defaults.integer(forKey: "totalSessionCount")
    }
    
    private func checkAndResetDailySession() {
        let defaults = UserDefaults.standard
        if let lastDate = defaults.object(forKey: "lastSessionDate") as? Date {
            let calendar = Calendar.current
            if !calendar.isDateInToday(lastDate) {
                // 日付が変わったので今日のセッション数をリセット
                todaySessionCount = 0
                defaults.set(0, forKey: "todaySessionCount")
                defaults.set(Date(), forKey: "lastSessionDate")
            }
        }
    }
    
    private func loadPomodoroSettings() {
        let defaults = UserDefaults.standard
        pomodoroWorkMinutes = defaults.integer(forKey: "pomodoroWorkMinutes") != 0 ? defaults.integer(forKey: "pomodoroWorkMinutes") : 25
        pomodoroShortBreakMinutes = defaults.integer(forKey: "pomodoroShortBreakMinutes") != 0 ? defaults.integer(forKey: "pomodoroShortBreakMinutes") : 5
        pomodoroLongBreakMinutes = defaults.integer(forKey: "pomodoroLongBreakMinutes") != 0 ? defaults.integer(forKey: "pomodoroLongBreakMinutes") : 15
        sessionsUntilLongBreak = defaults.integer(forKey: "sessionsUntilLongBreak") != 0 ? defaults.integer(forKey: "sessionsUntilLongBreak") : 4
    }
    
    func savePomodoroSettings() {
        let defaults = UserDefaults.standard
        defaults.set(pomodoroWorkMinutes, forKey: "pomodoroWorkMinutes")
        defaults.set(pomodoroShortBreakMinutes, forKey: "pomodoroShortBreakMinutes")
        defaults.set(pomodoroLongBreakMinutes, forKey: "pomodoroLongBreakMinutes")
        defaults.set(sessionsUntilLongBreak, forKey: "sessionsUntilLongBreak")
    }
}

extension Notification.Name {
    static let timerFinished = Notification.Name("timerFinished")
    static let pomodoroWorkFinished = Notification.Name("pomodoroWorkFinished")
    static let pomodoroBreakFinished = Notification.Name("pomodoroBreakFinished")
}

