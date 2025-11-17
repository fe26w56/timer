# パッケージ化ガイド

このドキュメントでは、ポモドーロタイマーアプリを配布用にパッケージ化する方法を説明します。

## 前提条件

- Xcodeがインストールされていること
- プロジェクトが正しくビルドできること
- コード署名が設定されていること（配布する場合）

## パッケージ化方法

### 方法1: スクリプトを使用（推奨）

```bash
./package.sh
```

このスクリプトは以下を自動的に実行します：
1. クリーンビルド
2. Archiveの作成
3. .appバンドルのエクスポート
4. DMGファイルの作成

### 方法2: Xcodeで手動ビルド

1. Xcodeでプロジェクトを開く
2. Product → Archive を選択
3. Organizerウィンドウが開いたら、Archiveを選択
4. "Distribute App" をクリック
5. 配布方法を選択（例: "Copy App"）
6. エクスポート先を選択

### 方法3: コマンドラインでビルド

```bash
# クリーンビルド
xcodebuild clean -project TimerApp/TimerApp.xcodeproj -scheme TimerApp

# Releaseビルド
xcodebuild build -project TimerApp/TimerApp.xcodeproj -scheme TimerApp -configuration Release

# Archive作成
xcodebuild archive \
    -project TimerApp/TimerApp.xcodeproj \
    -scheme TimerApp \
    -configuration Release \
    -archivePath build/TimerApp.xcarchive
```

## ビルド成果物

パッケージ化後、以下のファイルが生成されます：

- `build/export/TimerApp.app` - アプリケーション本体
- `build/TimerApp.dmg` - 配布用DMGファイル

## DMGファイルの配布

DMGファイルは以下の方法で配布できます：

1. **直接配布**: DMGファイルをそのまま配布
2. **GitHub Releases**: GitHubのリリースページにアップロード
3. **Webサイト**: 自分のWebサイトにアップロード

## 注意事項

- **コード署名**: 配布する場合は、有効な開発者証明書でコード署名する必要があります
- **公証（Notarization）**: macOS Catalina以降では、公証が必要な場合があります
- **Gatekeeper**: 未署名のアプリは、ユーザーがセキュリティ設定を変更する必要がある場合があります

## トラブルシューティング

### ビルドエラーが発生する場合

```bash
# DerivedDataをクリア
rm -rf ~/Library/Developer/Xcode/DerivedData

# プロジェクトをクリーン
xcodebuild clean -project TimerApp/TimerApp.xcodeproj -scheme TimerApp
```

### DMG作成に失敗する場合

- ディスク容量を確認してください
- `hdiutil`コマンドが利用可能か確認してください（通常はmacOSに標準搭載）

## 配布前のチェックリスト

- [ ] アプリが正常に動作することを確認
- [ ] コード署名が正しく設定されている
- [ ] Info.plistのバージョン情報が正しい
- [ ] アイコンが正しく設定されている
- [ ] DMGファイルが正常に開けることを確認

