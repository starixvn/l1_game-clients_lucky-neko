#!/bin/bash

# ShoeBox 自動化腳本執行器 (支持 Ctrl+C 中斷)

echo "🚀 開始執行 ShoeBox 自動化流程..."
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

# 執行第一個 AppleScript
echo "▶️ 步驟 1: 正在執行 position-shoebox.scpt..."
osascript position-shoebox.scpt &

# 獲取背景進程 PID
SCRIPT_PID=$!

# 等待腳本完成
wait $SCRIPT_PID

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 步驟 1 完成: position-shoebox.scpt 執行成功！"
    echo ""
    
    # 執行第二個 AppleScript
    echo "▶️ 步驟 2: 正在執行 replace-fonts-settings.scpt..."
    osascript replace-fonts-settings.scpt &
    
    # 獲取第二個腳本的 PID
    SCRIPT_PID2=$!
    
    # 等待第二個腳本完成
    wait $SCRIPT_PID2
    
    # 檢查第二個腳本的執行結果
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 所有步驟完成: ShoeBox 自動化流程執行完成！"
    else
        echo ""
        echo "❌ 步驟 2 失敗: replace-fonts-settings.scpt 執行錯誤"
    fi
else
    echo ""
    echo "❌ 步驟 1 失敗: position-shoebox.scpt 執行錯誤"
    echo "⏹️ 跳過步驟 2"
fi
