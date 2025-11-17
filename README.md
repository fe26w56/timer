# 集中モードタイマー

macOS向けのメニューバーアプリケーション。集中時間を管理するためのシンプルなタイマーです。

## 機能

- メニューバーに常駐するタイマーアプリ
- 1分〜120分の範囲で5分刻みの時間設定
- タイマー実行中はメニューバーに残り時間を表示
- 一時停止・再開機能
- タイマー終了時の通知（音なし）
- スヌーズ機能（10分追加）

## セットアップ方法

### Xcodeでプロジェクトを作成

1. Xcodeを開き、「Create a new Xcode project」を選択
2. 「macOS」→「App」を選択して「Next」
3. プロジェクト情報を入力：
   - Product Name: `TimerApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - 保存先: このディレクトリを選択
4. 「Create」をクリック

### ファイルの追加

作成されたXcodeプロジェクトに、以下のSwiftファイルを追加してください：

- `TimerApp.swift` - アプリのエントリーポイント
- `TimerManager.swift` - タイマー管理ロジック
- `StatusBarManager.swift` - メニューバー管理
- `PopupView.swift` - ポップアップUI

### ビルド設定

1. プロジェクトナビゲーターでプロジェクトを選択
2. 「Signing & Capabilities」タブで：
   - 「Automatically manage signing」にチェック
   - Teamを選択（個人開発の場合は個人のApple ID）
3. 「Build Settings」で：
   - 「macOS Deployment Target」を `11.0` 以上に設定

### 実行

1. プロダクトスキームで「TimerApp」を選択
2. 「Run」ボタンをクリック（⌘R）
3. メニューバーにタイマーアイコンが表示されます

## 使用方法

1. メニューバーのタイマーアイコンをクリック
2. スライダーで時間を設定（1分〜120分、5分刻み）
3. 「開始」ボタンをクリック
4. タイマー実行中はメニューバーに残り時間が表示されます
5. ポップアップから一時停止・再開・キャンセルが可能
6. タイマー終了時には通知が表示され、「停止」または「スヌーズ（10分追加）」を選択できます

## 技術スタック

- SwiftUI
- AppKit
- Combine

## 要件

- macOS 11.0以上
- Xcode 13.0以上

