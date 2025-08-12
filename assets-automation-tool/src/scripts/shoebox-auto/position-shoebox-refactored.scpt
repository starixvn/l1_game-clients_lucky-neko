-- Position ShoeBox Script (Refactored)
-- ShoeBox 定位腳本 (重構版)
-- 支援多種字體文件的拖拽處理

-- 取得命令行參數，默認為 font-multiplier
on run argv
    if (count of argv) > 0 then
        set fontType to item 1 of argv
    else
        set fontType to "font-multiplier"
    end if
    
    log "🚀 開始處理字體類型: " & fontType
    
    -- 根據字體類型設定圖片文件名和位置
    if fontType is "font-multiplier" then
        set imageFileName to "font-multiplier.png"
        set imagePosition to {220, 355} -- 第一個圖片的位置
    else if fontType is "font-number" then
        set imageFileName to "font-number.png"
        set imagePosition to {350, 355} -- 第二個圖片的位置 (假設在右邊)
    else
        log "❌ 不支援的字體類型: " & fontType
        return
    end if
    
    log "📁 目標圖片: " & imageFileName
    
    -- 開啟 Finder 目錄
    do shell script "/usr/bin/open /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/output/downloads/font-bitmap"
    delay 2
    
    -- 開啟 ShoeBox
    do shell script "/usr/bin/open -a /Applications/Shoebox.app"
    delay 4
    
    tell application "System Events"
        -- 設定 ShoeBox 視窗
        my setupShoeBoxWindow()
        
        -- 設定 Finder 視窗
        my setupFinderWindow()
        
        -- 拖拽指定的圖片文件
        my dragImageToShoeBox(imagePosition)
        
        -- 智能設定 Bitmap Font 窗口位置
        my setupBitmapFontWindow()
        
    end tell
end run

-- 設定 ShoeBox 主視窗
on setupShoeBoxWindow()
    tell application "System Events"
        tell process "ShoeBox"
            set frontmost to true
            try
                set allWindows to every window
                repeat with w in allWindows
                    try
                        set windowName to name of w
                        if windowName is "ShoeBox" then
                            set position of w to {0, 23}
                            set size of w to {500, 400}
                            exit repeat
                        end if
                    end try
                end repeat
                
                -- 點擊視窗確保活化
                do shell script "/opt/homebrew/bin/cliclick c:110,200"
                delay 0.5
                log "✅ ShoeBox 主視窗已設定"
            on error errMsg
                log "❌ 設定 ShoeBox 視窗失敗: " & errMsg
            end try
        end tell
    end tell
end setupShoeBoxWindow

-- 設定 Finder 視窗
on setupFinderWindow()
    tell application "System Events"
        tell process "Finder"
            set frontmost to true
            try
                -- 將 Finder 定位到 ShoeBox 下方
                set position of window 1 to {0, 250}
                set size of window 1 to {500, 400}
                
                -- 切換到圖像模式並排序
                key code 18 using command down -- Cmd+1 (圖像檢視)
                delay 0.5
                key code 5 using {command down, option down} -- 排列依據名稱
                delay 1
                
                log "✅ Finder 視窗已設定"
            on error errMsg
                log "❌ 設定 Finder 視窗失敗: " & errMsg
            end try
        end tell
    end tell
end setupFinderWindow

-- 拖拽圖片到 ShoeBox
on dragImageToShoeBox(imagePosition)
    try
        -- 確保 Finder 在前台
        tell application "System Events"
            tell process "Finder"
                set frontmost to true
            end tell
        end tell
        delay 1
        
        set imageX to item 1 of imagePosition
        set imageY to item 2 of imagePosition
        
        log "📌 準備拖拽圖片，位置: " & imageX & "," & imageY
        
        -- 點擊確認文件位置
        do shell script "/opt/homebrew/bin/cliclick c:" & imageX & "," & imageY
        delay 0.5
        
        -- 開始拖拽
        do shell script "/opt/homebrew/bin/cliclick m:" & imageX & "," & imageY
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick dd:" & imageX & "," & imageY
        delay 1
        
        -- 確保 ShoeBox 在前台
        tell application "System Events"
            tell process "ShoeBox"
                set frontmost to true
            end tell
        end tell
        delay 0.5
        
        -- 移動到目標位置並放下
        do shell script "/opt/homebrew/bin/cliclick dm:165,192"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick dm:110,110"
        delay 0.8
        do shell script "/opt/homebrew/bin/cliclick du:110,110"
        delay 2
        
        log "✅ 圖片拖拽完成"
        
    on error errMsg
        log "❌ 拖拽圖片失敗: " & errMsg
    end try
end dragImageToShoeBox

-- 智能設定 Bitmap Font 窗口位置
on setupBitmapFontWindow()
    delay 2
    try
        tell application "System Events"
            tell process "ShoeBox"
                set allWindows to every window
                set bitmapMoved to false
                
                -- 方法1: 尋找包含 "Bitmap" 或 "Font" 的窗口
                repeat with w in allWindows
                    try
                        set windowName to name of w
                        if windowName contains "Bitmap" or windowName contains "Font" or windowName contains "BitMap" then
                            set position of w to {520, 23}
                            set size of w to {400, 300}
                            set bitmapMoved to true
                            log "✅ 找到並設定 Bitmap Font 窗口 (方法1)"
                            exit repeat
                        end if
                    end try
                end repeat
                
                -- 方法2: 如果沒找到，尋找最大的空白窗口
                if not bitmapMoved then
                    set largestWindow to missing value
                    set largestSize to 0
                    
                    repeat with w in allWindows
                        try
                            set windowName to name of w
                            set windowSize to size of w
                            set windowArea to (item 1 of windowSize) * (item 2 of windowSize)
                            
                            if windowName is "" and windowArea > largestSize and windowArea > 50000 then
                                set largestWindow to w
                                set largestSize to windowArea
                            end if
                        end try
                    end repeat
                    
                    if largestWindow is not missing value then
                        set position of largestWindow to {520, 23}
                        set size of largestWindow to {400, 300}
                        set bitmapMoved to true
                        log "✅ 設定 Bitmap Font 窗口 (方法2)"
                    end if
                end if
                
                -- 方法3: 設定第一個非ShoeBox窗口
                if not bitmapMoved then
                    repeat with w in allWindows
                        try
                            set windowName to name of w
                            if windowName is not "ShoeBox" then
                                set position of w to {520, 23}
                                set size of w to {400, 300}
                                log "✅ 設定 Bitmap Font 窗口 (方法3)"
                                exit repeat
                            end if
                        end try
                    end repeat
                end if
            end tell
        end tell
        
    on error errMsg
        log "❌ 設定 Bitmap Font 窗口失敗: " & errMsg
    end try
end setupBitmapFontWindow
