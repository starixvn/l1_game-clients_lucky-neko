#!/bin/bash

# Test File Positions
# 測試檔案位置工具

echo "🔍 檔案位置測試工具"
echo "=================="

# 確保在正確目錄
cd "$(dirname "$0")"

# 開啟 Finder 視窗
echo "📂 開啟 Finder 視窗..."
open /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/output/downloads/font-bitmap
sleep 3

echo ""
echo "🎯 測試所有檔案位置搜尋方法"
echo "=========================="

FILES=("font-multiplier.png" "font-number.png")

for file in "${FILES[@]}"; do
    echo ""
    echo "📁 測試檔案: $file"
    echo "------------------------"
    
    # 方法 1: 原始工具
    echo "🔍 方法 1: find-file-position.sh"
    position1=$(./find-file-position.sh "$file" 2>/dev/null)
    echo "   結果: $position1"
    
    # 方法 2: 增強版 AppleScript
    echo "🔍 方法 2: enhanced-file-finder.scpt"
    position2=$(osascript enhanced-file-finder.scpt "$file" 2>/dev/null)
    echo "   結果: $position2"
    
    # 方法 3: UI 搜尋
    echo "🔍 方法 3: UI 搜尋"
    position3=$(./find-file-position.sh "$file" ui 2>/dev/null)
    echo "   結果: $position3"
    
    # 方法 4: 網格搜尋
    echo "🔍 方法 4: 網格搜尋"
    position4=$(./find-file-position.sh "$file" grid 2>/dev/null)
    echo "   結果: $position4"
    
    # 驗證位置 (移動滑鼠到找到的位置)
    if [[ "$position1" =~ ^[0-9]+,[0-9]+$ ]]; then
        echo "✅ 移動滑鼠到找到的位置進行驗證: $position1"
        cliclick m:$position1
        sleep 1
        
        # 檢查滑鼠位置下的元素
        element_check=$(osascript << EOF
tell application "System Events"
    tell process "Finder"
        try
            set pos_parts to my split("$position1", ",")
            set test_x to item 1 of pos_parts as number
            set test_y to item 2 of pos_parts as number
            
            set elementAtPos to UI element at {test_x, test_y}
            return name of elementAtPos
        on error
            return "NO_ELEMENT"
        end try
    end tell
end tell

on split(input, delimiter)
    set AppleScript's text item delimiters to delimiter
    set output to text items of input
    set AppleScript's text item delimiters to ""
    return output
end split
EOF
)
        echo "   位置元素: $element_check"
    fi
    
    echo ""
done

echo ""
echo "🎯 手動驗證建議位置"
echo "=================="

echo "請手動點擊檔案並記錄滑鼠位置："
echo "1. font-multiplier.png (預期: 254,387)"
echo "2. font-number.png (預期: 400,470)"
echo ""
echo "使用以下命令來檢查滑鼠當前位置："
echo "osascript -e 'tell application \"System Events\" to return mouse location'"
