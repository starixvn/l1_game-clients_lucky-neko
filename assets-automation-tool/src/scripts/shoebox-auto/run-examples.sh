#!/bin/bash

# ShoeBox 自動化腳本使用示例
# 此腳本提供了三種字體文件的處理示例

echo "📚 ShoeBox 自動化腳本使用示例"
echo "=================================="
echo ""
echo "請選擇要處理的字體文件："
echo "1) font-multiplier.png (倍數字體)"
echo "2) font-number.png (數字字體)"
echo "3) font-win-money.png (贏錢字體)"
echo "4) 查看使用說明"
echo ""

read -p "請輸入選項 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🎯 執行 font-multiplier.png 處理..."
        ./run-with-interrupt.sh font-multiplier.png
        ;;
    2)
        echo ""
        echo "🎯 執行 font-number.png 處理..."
        ./run-with-interrupt.sh font-number.png
        ;;
    3)
        echo ""
        echo "🎯 執行 font-win-money.png 處理..."
        ./run-with-interrupt.sh font-win-money.png
        ;;
    4)
        echo ""
        echo "📖 使用說明："
        echo "============="
        echo ""
        echo "1. 直接執行命令："
        echo "   ./run-with-interrupt.sh                     # 預設處理 font-multiplier.png"
        echo "   ./run-with-interrupt.sh font-multiplier.png # 處理 font-multiplier.png"
        echo "   ./run-with-interrupt.sh font-number.png     # 處理 font-number.png"
        echo "   ./run-with-interrupt.sh font-win-money.png  # 處理 font-win-money.png"
        echo ""
        echo "2. 腳本會自動："
        echo "   - 開啟 Finder 到 font-bitmap 資料夾"
        echo "   - 開啟 ShoeBox 應用程式"
        echo "   - 拖拽指定的字體文件到 ShoeBox"
        echo "   - 載入對應的配置文件 (.sbx)"
        echo "   - 自動配置 File Format 設定"
        echo "   - 套用設定並儲存"
        echo ""
        echo "3. 按 Ctrl+C 可隨時中斷腳本執行"
        echo ""
        echo "4. 確保以下文件存在："
        echo "   - config/shoebox-config/font-multiplier-config.json"
        echo "   - config/shoebox-config/font-number-config.json"
        echo "   - config/shoebox-config/font-win-money-config.json"
        echo "   - config/shoebox-config/image-heights.json"
        echo ""
        ;;
    *)
        echo ""
        echo "❌ 無效的選項，請重新執行並選擇 1-4"
        exit 1
        ;;
esac
