#!/bin/bash

# Position Verification Tool
# 位置驗證工具 - 驗證檔案位置是否正確

echo "🎯 檔案位置驗證工具"
echo "=================="

# 確保在正確目錄
cd "$(dirname "$0")"

# 開啟 Finder 視窗
echo "📂 開啟 Finder 視窗..."
open /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/output/downloads/font-bitmap
sleep 3

echo ""
echo "🔍 驗證檔案位置"
echo "=============="

FILES=("font-multiplier.png:254,387" "font-number.png:400,470")

for file_info in "${FILES[@]}"; do
    IFS=':' read -r filename expected_pos <<< "$file_info"
    
    echo ""
    echo "📁 檔案: $filename"
    echo "📍 預期位置: $expected_pos"
    echo "------------------------"
    
    # 搜尋實際位置
    actual_pos=$(./find-file-position.sh "$filename" 2>/dev/null)
    echo "🔍 搜尋結果: $actual_pos"
    
    # 比較位置
    if [ "$actual_pos" = "$expected_pos" ]; then
        echo "✅ 位置正確匹配！"
    else
        echo "⚠️ 位置不匹配"
        echo "   預期: $expected_pos"
        echo "   實際: $actual_pos"
    fi
    
    # 移動滑鼠到位置進行視覺驗證
    if [[ "$actual_pos" =~ ^[0-9]+,[0-9]+$ ]]; then
        echo "🎯 移動滑鼠到該位置 (3秒後移動)..."
        sleep 1
        echo "3..."
        sleep 1
        echo "2..."
        sleep 1
        echo "1..."
        
        cliclick m:$actual_pos
        echo "📍 滑鼠已移動到 $actual_pos"
        echo "請檢查滑鼠是否在 $filename 上方"
        
        # 取得該位置的元素資訊
        element_info=$(osascript << EOF
tell application "System Events"
    tell process "Finder"
        try
            set pos_parts to my split("$actual_pos", ",")
            set test_x to item 1 of pos_parts as number
            set test_y to item 2 of pos_parts as number
            
            set elementAtPos to UI element at {test_x, test_y}
            set elementName to name of elementAtPos
            set elementRole to role of elementAtPos
            
            return "名稱: " & elementName & ", 類型: " & elementRole
        on error errMsg
            return "錯誤: " & errMsg
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
        echo "🔍 位置元素: $element_info"
        
        # 等待用戶確認
        echo ""
        read -p "請確認滑鼠是否正確指向 $filename ? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            echo "✅ 位置驗證成功！"
        else
            echo "❌ 位置需要調整"
            echo "請告訴我正確的座標，我會更新設定"
        fi
    fi
done

echo ""
echo "🛠️ 進階驗證選項"
echo "==============="

echo "1. 測試拖拽到滑鼠當前位置:"
echo "   cliclick -p"
echo ""

echo "2. 取得滑鼠當前位置:"
echo "   osascript -e 'tell application \"System Events\" to return mouse location'"
echo ""

echo "3. 手動測試拖拽:"
echo "   ./smart-drag-tool.sh font-number.png"
echo ""

echo "4. 如果位置不正確，請執行:"
echo "   echo '新的X,Y座標' | 並告訴我更新設定"
