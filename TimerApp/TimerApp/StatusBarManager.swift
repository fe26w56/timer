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
        
        // メニューバーアイテムを作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else {
            print("StatusBarManager: Failed to get button")
            return
        }
        
        print("StatusBarManager: Status item created")
        
        // 初期アイコンを設定
        updateStatusBar()
        
        // クリックイベントを設定
        button.action = #selector(togglePopover)
        button.target = self
        
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
            button.title = timerManager.formattedTime
            button.image = nil
            
        case .paused:
            button.title = "⏸ \(timerManager.formattedTime)"
            button.image = nil
        }
        
        // ボタンを表示状態にする
        button.isHidden = false
    }
}

