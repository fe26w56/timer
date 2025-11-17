import SwiftUI
import AppKit

@main
struct TimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        print("TimerApp: Initializing...")
    }
    
    var body: some Scene {
        // メニューバーアプリなのでウィンドウは表示しない
        // Settings Sceneを使用（表示されない）
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("AppDelegate: applicationWillFinishLaunching called")
        // アプリがメニューバーにのみ表示されるように設定
        NSApp.setActivationPolicy(.accessory)
        print("AppDelegate: Activation policy set to accessory")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching called")
        
        // メニューバーを初期化
        DispatchQueue.main.async { [weak self] in
            print("AppDelegate: Initializing status bar in async block")
            self?.initializeStatusBar()
        }
    }
    
    private func initializeStatusBar() {
        print("AppDelegate: initializeStatusBar called")
        // シングルトンインスタンスを使用
        let manager = TimerManager.shared
        let statusBar = StatusBarManager.shared
        
        print("AppDelegate: Calling statusBar.setup()")
        statusBar.setup(timerManager: manager)
        
        // タイマー終了通知を監視
        NotificationCenter.default.addObserver(
            forName: .timerFinished,
            object: nil,
            queue: .main
        ) { _ in
            StatusBarManager.shared.showCompletionAlert()
        }
        print("AppDelegate: initializeStatusBar completed")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("AppDelegate: applicationWillTerminate called")
    }
}

