import AppKit
import SwiftUI
import Combine

class StatusBarManager: ObservableObject {
    static let shared = StatusBarManager()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var timerManager: TimerManager?
    private var isSetup = false
    
    private init() {}
    
    func setup(timerManager: TimerManager) {
        // 既にセットアップ済みの場合はスキップ
        guard !isSetup else {
            print("StatusBarManager: Already setup, skipping...")
            return
        }
        
        print("StatusBarManager: Starting setup...")
        self.timerManager = timerManager
        
        // メニューバーアイテムを作成（固定幅で作成して幅の変動を防ぐ）
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else {
            print("StatusBarManager: Failed to get button")
            return
        }
        
        print("StatusBarManager: Status item created")
        
        // 等幅フォントを使用して数字の幅を固定
        button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        // 最小幅を設定して幅の変動を防ぐ
        button.frame.size.width = 80
        
        // 初期アイコンを設定
        updateStatusBar()
        
        // 右クリック（Control+クリック）でメニューを表示するために設定
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        // クリックイベントを設定
        button.action = #selector(handleButtonClick(_:))
        button.target = self
        
        // 右クリック用のメニューを作成
        createContextMenu()
        
        // ポップオーバーを作成
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: PopupView())
        
        // タイマー状態の変更を監視
        timerManager.$state
            .combineLatest(timerManager.$remainingSeconds)
            .sink { [weak self] _, _ in
                DispatchQueue.main.async {
                    self?.updateStatusBar()
                }
            }
            .store(in: &cancellables)
        
        isSetup = true
        print("StatusBarManager: Setup completed")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @objc func handleButtonClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // 右クリックの場合はメニューを表示
            showContextMenu()
        } else {
            // 左クリックの場合はポップオーバーを表示
            togglePopover()
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button,
              let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // ポップオーバーを表示
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // ポップオーバー内のビューを更新
            if let hostingController = popover.contentViewController as? NSHostingController<PopupView> {
                hostingController.rootView = PopupView()
            }
        }
    }
    
    private var contextMenu: NSMenu?
    
    private func createContextMenu() {
        let menu = NSMenu()
        
        let quitItem = NSMenuItem(title: "終了", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        contextMenu = menu
        // statusItem.menuは設定しない（左クリックでメニューが表示されないようにするため）
    }
    
    private func showContextMenu() {
        guard let button = statusItem?.button,
              let menu = contextMenu else { return }
        
        // メニューを表示
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
    
    func showCompletionAlert() {
        guard let button = statusItem?.button else { return }
        
        // ポップオーバーを閉じる
        popover?.performClose(nil)
        
        // アラートウィンドウを表示
        let alert = NSAlert()
        alert.messageText = "タイマーが終了しました"
        alert.informativeText = "集中時間が終了しました。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "停止")
        alert.addButton(withTitle: "スヌーズ（10分追加）")
        
        // メインウィンドウを前面に
        NSApp.activate(ignoringOtherApps: true)
        
        let response = alert.runModal()
        
        if response == .alertSecondButtonReturn {
            // スヌーズ
            timerManager?.snooze()
        } else {
            // 停止
            timerManager?.stop()
        }
        
        updateStatusBar()
    }
    
    func showPomodoroWorkFinishedAlert(isLongBreak: Bool) {
        guard let button = statusItem?.button else { return }
        
        // ポップオーバーを閉じる
        popover?.performClose(nil)
        
        // アラートウィンドウを表示
        let alert = NSAlert()
        alert.messageText = isLongBreak ? "長い休憩の時間です" : "短い休憩の時間です"
        alert.informativeText = isLongBreak ? 
            "お疲れ様でした！長い休憩を取ってください。" :
            "お疲れ様でした！短い休憩を取ってください。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "休憩を開始")
        
        // メインウィンドウを前面に
        NSApp.activate(ignoringOtherApps: true)
        
        alert.runModal()
        
        updateStatusBar()
    }
    
    func showPomodoroBreakFinishedAlert() {
        guard let button = statusItem?.button else { return }
        
        // ポップオーバーを閉じる
        popover?.performClose(nil)
        
        // アラートウィンドウを表示
        let alert = NSAlert()
        alert.messageText = "休憩が終了しました"
        alert.informativeText = "作業を再開しましょう！"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "作業を開始")
        
        // メインウィンドウを前面に
        NSApp.activate(ignoringOtherApps: true)
        
        alert.runModal()
        
        updateStatusBar()
    }
    
    private func updateStatusBar() {
        guard let button = statusItem?.button,
              let timerManager = timerManager else {
            print("StatusBarManager: Cannot update status bar - button or timerManager is nil")
            return
        }
        
        switch timerManager.state {
        case .idle:
            button.title = "⏱"
            button.image = nil
            
        case .running:
            if timerManager.isPomodoroMode {
                button.title = "🍅 \(timerManager.formattedTime)"
            } else {
                button.title = timerManager.formattedTime
            }
            button.image = nil
            
        case .paused:
            button.title = "⏸ \(timerManager.formattedTime)"
            button.image = nil
            
        case .shortBreak:
            button.title = "☕ \(timerManager.formattedTime)"
            button.image = nil
            
        case .longBreak:
            button.title = "🌴 \(timerManager.formattedTime)"
            button.image = nil
        }
        
        // ボタンを表示状態にする
        button.isHidden = false
    }
}

