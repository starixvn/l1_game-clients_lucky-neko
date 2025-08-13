#!/bin/bash

# Smart Drag Tool
# 智能拖拽工具 - 自動搜尋檔案並執行拖拽

echo "🎯 智能拖拽工具"
echo "================"

# 顯示使用說明
show_help() {
    echo "使用方法: $0 <檔案名稱> [目標X] [目標Y]"
    echo ""
    echo "參數說明:"
    echo "  檔案名稱    - 要拖拽的檔案名稱"
    echo "  目標X       - 目標位置 X 座標 (預設: 110)"
    echo "  目標Y       - 目標位置 Y 座標 (預設: 110)"
    echo ""
    echo "範例:"
    echo "  $0 font-multiplier.png           # 拖拽到預設位置 (110,110)"
    echo "  $0 font-number.png 200 200      # 拖拽到指定位置 (200,200)"
    echo ""
    echo "功能:"
    echo "  ✅ 自動搜尋檔案在螢幕上的位置"
    echo "  ✅ 智能拖拽到目標位置"
    echo "  ✅ 多種搜尋方法備援"
    echo "  ✅ 詳細的執行日誌"
    echo ""
}

# 檢查參數
if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

FILENAME=$1
TARGET_X=${2:-110}
TARGET_Y=${3:-110}

echo "📁 目標檔案: $FILENAME"
echo "🎯 目標位置: ($TARGET_X, $TARGET_Y)"
echo ""

# 檢查依賴工具
check_dependencies() {
    local missing_tools=()
    
    if ! command -v cliclick &> /dev/null; then
        missing_tools+=("cliclick")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "❌ 缺少必要工具: ${missing_tools[*]}"
        echo "請安裝: brew install ${missing_tools[*]}"
        exit 1
    fi
}

# 確保 Finder 在前台並準備好
prepare_finder() {
    echo "📂 準備 Finder 環境..."
    
    # 啟動並置於前台
    osascript << EOF
tell application "Finder"
    activate
    delay 1
end tell
EOF
    
    # 檢查是否有開啟的視窗
    local window_count=$(osascript << EOF
tell application "System Events"
    tell process "Finder"
        return count of windows
    end tell
end tell
EOF
)
    
    if [ "$window_count" -eq 0 ]; then
        echo "❌ 沒有開啟的 Finder 視窗"
        echo "請先開啟包含 $FILENAME 的資料夾"
        exit 1
    fi
    
    echo "✅ Finder 準備完成"
}



# 確保目標應用程式準備好
prepare_target_app() {
    echo "🎯 準備目標應用程式 (ShoeBox)..."
    
    # 檢查 ShoeBox 是否運行
    local shoebox_running=$(osascript << EOF
tell application "System Events"
    return (count of (every process whose name is "ShoeBox")) > 0
end tell
EOF
)
    
    if [ "$shoebox_running" = "false" ]; then
        echo "⚠️ ShoeBox 未運行，嘗試啟動..."
        open -a "/Applications/Shoebox.app"
        sleep 3
    fi
    
    # 確保 ShoeBox 視窗可見
    osascript << EOF
tell application "System Events"
    tell process "ShoeBox"
        set frontmost to true
        delay 0.5
    end tell
end tell
EOF
    
    echo "✅ 目標應用程式準備完成"
}

# 執行拖拽操作 (參考原本可行的方法)
perform_drag() {
    local source_position=$1
    local target_x=$2
    local target_y=$3
    
    # 解析源位置
    IFS=',' read -r source_x source_y <<< "$source_position"
    
    echo "🎯 執行拖拽操作..."
    echo "   源位置: ($source_x, $source_y)"
    echo "   目標位置: ($target_x, $target_y)"
    
    # 確保 Finder 在前台
    osascript << EOF
tell application "System Events"
    tell process "Finder"
        set frontmost to true
        delay 0.5
    end tell
end tell
EOF
    
    # 步驟1: 點擊確認檔案位置
    echo "   🔄 點擊確認檔案位置..."
    cliclick c:$source_x,$source_y
    sleep 0.5
    
    # 步驟2: 移動到檔案位置並開始拖拽
    echo "   🔄 開始拖拽..."
    cliclick m:$source_x,$source_y
    sleep 0.5
    cliclick dd:$source_x,$source_y
    sleep 1
    
    # 步驟3: 確保 ShoeBox 在前台
    echo "   🔄 切換到 ShoeBox..."
    osascript << EOF
tell application "System Events"
    tell process "ShoeBox"
        set frontmost to true
        delay 0.5
    end tell
end tell
EOF
    
    # 步驟4: 分段移動到目標位置 (模仿原本的成功方法)
    echo "   🔄 分段移動到目標位置..."
    
    # 先移動到中間位置
    cliclick dm:165,192
    sleep 0.5
    
    # 再移動到最終目標位置
    cliclick dm:$target_x,$target_y
    sleep 0.8
    
    # 步驟5: 結束拖拽
    echo "   🔄 完成拖拽..."
    cliclick du:$target_x,$target_y
    sleep 2
    
    echo "✅ 拖拽操作完成！"
}

# 驗證拖拽結果
verify_drag_result() {
    echo "🔍 驗證拖拽結果..."
    
    # 檢查 ShoeBox 是否有新的視窗或變化
    sleep 2
    
    local window_count=$(osascript << EOF
tell application "System Events"
    tell process "ShoeBox"
        return count of windows
    end tell
end tell
EOF
)
    
    if [ "$window_count" -gt 1 ]; then
        echo "✅ 偵測到新視窗，拖拽可能成功"
        return 0
    else
        echo "⚠️ 未偵測到明顯變化，請手動確認結果"
        return 1
    fi
}

# 主程式
main() {
    echo "🚀 開始智能拖拽流程..."
    echo ""
    
    # 檢查依賴
    check_dependencies
    
    # 準備 Finder
    prepare_finder
    
    # 搜尋檔案位置
    echo "🔍 搜尋檔案位置: $FILENAME"
    local file_position
    file_position=$(./find-file-position.sh "$FILENAME" auto 2>/dev/null)
    local search_result=$?
    
    if [ $search_result -ne 0 ] || ! [[ "$file_position" =~ ^[0-9]+,[0-9]+$ ]]; then
        echo "❌ 無法找到檔案位置，搜尋結果: $file_position"
        exit 1
    fi
    
    echo "✅ 找到檔案位置: $file_position"
    
    # 準備目標應用程式
    prepare_target_app
    
    # 執行拖拽
    perform_drag "$file_position" "$TARGET_X" "$TARGET_Y"
    
    # 驗證結果
    verify_drag_result
    
    echo ""
    echo "🎉 智能拖拽流程完成！"
    echo "📍 檔案已從 $file_position 拖拽到 ($TARGET_X, $TARGET_Y)"
}

# 錯誤處理
trap 'echo "❌ 拖拽過程中發生錯誤，正在清理..."; cliclick du:0,0; exit 1' ERR

# 執行主程式
main

