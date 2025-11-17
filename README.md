# 集中モードタイマー

macOS向けのメニューバーアプリケーション。集中時間を管理するためのシンプルなタイマーです。

## 機能

- メニューバーに常駐するタイマーアプリ
- 1分〜120分の範囲で5分刻みの時間設定
- タイマー実行中はメニューバーに残り時間を表示
- 一時停止・再開機能
- タイマー終了時の通知（音なし）
- スヌーズ機能（10分追加）
- **ポモドーロタイマーモード**
  - 25分作業 + 5分休憩の自動サイクル
  - 4セッションごとに15分の長い休憩
  - セッション数の記録（今日のセッション数、累計セッション数）
  - カスタマイズ可能な時間設定

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

## パッケージ化

アプリを配布用にパッケージ化するには、`package.sh`スクリプトを使用します：

```bash
./package.sh
```

詳細は [PACKAGING.md](PACKAGING.md) を参照してください。

## 技術スタック

- SwiftUI
- AppKit
- Combine

## 要件

- macOS 11.0以上
- Xcode 13.0以上

## Gitの運用方法

このプロジェクトのGitリポジトリの基本的な使い方を説明します。

### 基本的な流れ

1. **変更を確認する**
   ```bash
   git status
   ```
   現在の変更状況を確認できます。

2. **変更をステージングする**
   ```bash
   git add .
   ```
   すべての変更をステージングエリアに追加します。
   
   特定のファイルだけ追加する場合：
   ```bash
   git add ファイル名
   ```

3. **コミットする**
   ```bash
   git commit -m "変更内容の説明"
   ```
   例：`git commit -m "タイマー機能を追加"`

4. **リモートにプッシュする**
   ```bash
   git push origin main
   ```
   変更をGitHubにアップロードします。

### よく使うコマンド

- **変更履歴を確認**
  ```bash
  git log
  ```

- **最新の変更を取得**
  ```bash
  git pull origin main
  ```

- **変更を取り消す（まだコミットしていない場合）**
  ```bash
  git restore ファイル名
  ```

- **直前のコミットを取り消す（まだプッシュしていない場合）**
  ```bash
  git reset --soft HEAD~1
  ```

### 初回設定（GitHubにプッシュする場合）

1. **GitHubでリポジトリを作成**
   - GitHubにログインして新しいリポジトリを作成

2. **認証設定**
   - Personal Access Token（PAT）を使用する方法：
     - GitHubのSettings → Developer settings → Personal access tokens → Tokens (classic)
     - 新しいトークンを生成（`repo`権限が必要）
     - プッシュ時にユーザー名とトークンを入力
   
   - SSH鍵を使用する方法：
     ```bash
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
     生成された公開鍵をGitHubに登録

3. **リモートリポジトリを設定**
   ```bash
   git remote add origin https://github.com/ユーザー名/リポジトリ名.git
   ```

### 注意事項

- コミットメッセージは変更内容がわかるように書く
- 定期的に`git pull`して最新の変更を取得する
- 大きな変更は小さく分けてコミットする
- `.env`ファイルなど機密情報はコミットしない（`.gitignore`に追加）

