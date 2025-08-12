#!/bin/bash

# ShoeBox 字體自動化執行器
# 支援多種字體類型的自動化處理

echo "🚀 ShoeBox 字體自動化工具"
echo "=========================="
echo ""

# 顯示可用的字體類型
show_help() {
    echo "使用方法: $0 [字體類型]"
    echo ""
    echo "可用的字體類型:"
    echo "  font-multiplier    - 處理 font-multiplier.png"
    echo "  font-number        - 處理 font-number.png"
    echo ""
    echo "範例:"
    echo "  $0 font-multiplier"
    echo "  $0 font-number"
    echo ""
}

# 檢查參數
if [ $# -eq 0 ]; then
    echo "❌ 請指定字體類型"
    echo ""
    show_help
    exit 1
fi

FONT_TYPE=$1

# 驗證字體類型
case $FONT_TYPE in
    "font-multiplier"|"font-number")
        echo "✅ 字體類型: $FONT_TYPE"
        ;;
    "--help"|"-h")
        show_help
        exit 0
        ;;
    *)
        echo "❌ 不支援的字體類型: $FONT_TYPE"
        echo ""
        show_help
        exit 1
        ;;
esac

echo "💡 按 Ctrl+C 可以隨時中斷腳本"
echo ""

# 設定中斷信號處理
cleanup() {
    echo ""
    echo "❌ 檢測到中斷信號 (Ctrl+C)"
    echo "🛑 正在停止所有腳本執行..."
    
    # 殺死所有相關進程
    pkill -f "osascript.*position-shoebox"
    pkill -f "osascript.*replace-fonts-settings"
    pkill -f "cliclick"
    
    echo "✅ 所有腳本已安全停止"
    exit 1
}

# 註冊信號處理器
trap cleanup SIGINT SIGTERM

# 切換到腳本目錄
cd "$(dirname "$0")"

# 執行第一步：定位視窗和拖拽圖片
echo "▶️ 步驟 1: 正在執行視窗定位和圖片拖拽..."
echo "   處理文件: $FONT_TYPE"
osascript position-shoebox-refactored.scpt "$FONT_TYPE" &

# 獲取背景進程 PID
SCRIPT_PID=$!

# 等待腳本完成
wait $SCRIPT_PID

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 步驟 1 完成: 視窗定位和圖片拖拽成功！"
    echo ""
    
    # 短暫等待確保視窗穩定
    echo "⏳ 等待視窗穩定..."
    sleep 2
    
    # 執行第二步：字體設定替換
    echo "▶️ 步驟 2: 正在執行字體設定替換..."
    echo "   配置類型: $FONT_TYPE"
    osascript replace-fonts-settings-refactored.scpt "$FONT_TYPE" &
    
    # 獲取第二個腳本的 PID
    SCRIPT_PID2=$!
    
    # 等待第二個腳本完成
    wait $SCRIPT_PID2
    
    # 檢查第二個腳本的執行結果
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 所有步驟完成！"
        echo "✅ $FONT_TYPE 字體自動化處理成功完成"
        echo ""
        echo "📁 檢查輸出文件:"
        if [ "$FONT_TYPE" = "font-multiplier" ]; then
            echo "   - font-multiplier.fnt"
            echo "   - font-multiplier.png"
        elif [ "$FONT_TYPE" = "font-number" ]; then
            echo "   - font-number.fnt"
            echo "   - font-number.png"
        fi
    else
        echo ""
        echo "❌ 步驟 2 失敗: 字體設定替換執行錯誤"
        echo "💡 建議檢查 Shoebox 是否正確安裝和配置"
    fi
else
    echo ""
    echo "❌ 步驟 1 失敗: 視窗定位和圖片拖拽執行錯誤"
    echo "⏹️ 跳過步驟 2"
    echo "💡 建議檢查："
    echo "   - Shoebox 應用程式是否已安裝"
    echo "   - cliclick 工具是否已安裝 (brew install cliclick)"
    echo "   - 圖片文件是否存在於指定目錄"
fi

echo ""
echo "🏁 腳本執行結束"
