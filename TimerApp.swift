import SwiftUI
import AppKit

@main
struct TimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // アプリがメニューバーにのみ表示されるように設定
        NSApp.setActivationPolicy(.accessory)
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App構造体のインスタンスにアクセスするために遅延
        DispatchQueue.main.async {
            // NSApplication.shared.delegateからAppDelegateを取得
            guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
            
            // TimerAppのインスタンスを取得する方法がないため、
            // グローバルにアクセス可能な方法を使用
            // 実際には、AppDelegate内で直接作成する方が確実
            initializeStatusBar()
        }
    }
    
    private func initializeStatusBar() {
        // シングルトンインスタンスを使用
        let manager = TimerManager.shared
        let statusBar = StatusBarManager.shared
        
        statusBar.setup(timerManager: manager)
        
        // タイマー終了通知を監視
        NotificationCenter.default.addObserver(
            forName: .timerFinished,
            object: nil,
            queue: .main
        ) { _ in
            StatusBarManager.shared.showCompletionAlert()
        }
    }
}

