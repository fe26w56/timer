#!/bin/bash

# ポモドーロタイマーアプリのパッケージ化スクリプト
# 使用方法: ./package.sh

set -e

# プロジェクト設定
PROJECT_NAME="TimerApp"
SCHEME_NAME="TimerApp"
CONFIGURATION="Release"
BUILD_DIR="build"
DMG_NAME="${PROJECT_NAME}.dmg"
APP_NAME="${PROJECT_NAME}.app"

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ポモドーロタイマー パッケージ化スクリプト ===${NC}"

# 1. クリーンビルド
echo -e "\n${YELLOW}[1/4] クリーンビルドを実行中...${NC}"
xcodebuild clean \
    -project "TimerApp/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}"

# 2. Archiveを作成
echo -e "\n${YELLOW}[2/4] Archiveを作成中...${NC}"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
xcodebuild archive \
    -project "TimerApp/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -derivedDataPath "${BUILD_DIR}/DerivedData"

# 3. .appバンドルをエクスポート
echo -e "\n${YELLOW}[3/4] .appバンドルをエクスポート中...${NC}"
EXPORT_PATH="${BUILD_DIR}/export"
mkdir -p "${EXPORT_PATH}"

# Archiveから.appをコピー
if [ -d "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}" ]; then
    cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}" "${EXPORT_PATH}/"
    echo -e "${GREEN}✓ .appバンドルをエクスポートしました: ${EXPORT_PATH}/${APP_NAME}${NC}"
else
    echo -e "${RED}✗ .appバンドルが見つかりません${NC}"
    exit 1
fi

# 4. DMGファイルを作成
echo -e "\n${YELLOW}[4/4] DMGファイルを作成中...${NC}"
DMG_TEMP="${BUILD_DIR}/dmg_temp"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

# 既存のDMGを削除
rm -rf "${DMG_TEMP}"
rm -f "${DMG_PATH}"

# DMG用の一時ディレクトリを作成
mkdir -p "${DMG_TEMP}"

# .appをコピー
cp -R "${EXPORT_PATH}/${APP_NAME}" "${DMG_TEMP}/"

# Applicationsフォルダへのシンボリックリンクを作成
ln -s /Applications "${DMG_TEMP}/Applications"

# DMGを作成
hdiutil create -volname "${PROJECT_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "${DMG_PATH}"

# 一時ディレクトリを削除
rm -rf "${DMG_TEMP}"

echo -e "\n${GREEN}=== パッケージ化完了 ===${NC}"
echo -e "${GREEN}✓ DMGファイル: ${DMG_PATH}${NC}"
echo -e "${GREEN}✓ .appバンドル: ${EXPORT_PATH}/${APP_NAME}${NC}"
echo -e "\n${YELLOW}DMGファイルを開くには: open ${DMG_PATH}${NC}"

