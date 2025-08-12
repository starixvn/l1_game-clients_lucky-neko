-- Replace Fonts Settings Script (Refactored)
-- 替換字體設定腳本 (重構版)
-- 支援多種字體類型的自動化處理

-- 取得命令行參數，默認為 font-multiplier
on run argv
    if (count of argv) > 0 then
        set fontType to item 1 of argv
    else
        set fontType to "font-multiplier"
    end if
    
    log "🚀 開始處理字體類型: " & fontType
    
    -- 根據字體類型設定配置文件路徑
    if fontType is "font-multiplier" then
        set configFileName to "font-multiplier-config.json"
        set shoeboxConfigFile to "font-multiplier.sbx"
        set imageFileName to "font-multiplier.png"
        set configKey to "font-multiplier"
    else if fontType is "font-number" then
        set configFileName to "font-number-config.json"
        set shoeboxConfigFile to "font-number.sbx"
        set imageFileName to "font-number.png"
        set configKey to "font-number"
    else
        log "❌ 不支援的字體類型: " & fontType
        return
    end if
    
    -- 設定配置文件路徑
    set basePath to "/Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/config"
    set configFilePath to basePath & "/" & configFileName
    set shoeboxConfigPath to basePath & "/shoebox-config/" & shoeboxConfigFile
    set imageHeightsPath to basePath & "/image-heights.json"
    
    log "📁 配置文件: " & configFilePath
    log "📁 Shoebox 配置: " & shoeboxConfigPath
    
    tell application "System Events"
        tell process "ShoeBox"
            set frontmost to true
            delay 0.5
            
            -- 開啟對應的 shoebox 配置文件
            do shell script "open -a 'Shoebox' " & quoted form of shoeboxConfigPath
            delay 1
            log "✅ 已開啟 Shoebox 配置: " & shoeboxConfigFile
            
            -- 找到並設定 Bitmap Font 窗口
            my setupBitmapFontWindow()
            
            -- 開啟 Settings 窗口
            my openSettingsWindow()
            
            -- 讀取配置文件
            try
                set configContent to do shell script "cat " & quoted form of configFilePath
                set imageHeightsContent to do shell script "cat " & quoted form of imageHeightsPath
                
                -- 取得字體高度
                set fontHeight to my getFontHeight(imageHeightsContent, imageFileName)
                log "✅ 字體高度: " & fontHeight
                
                -- 更新字體設定
                my updateFontSettings(configContent, configKey, fontHeight)
                
                -- 儲存設定
                my saveSettings()
                
                log "🎉 " & fontType & " 字體設定完成！"
                
            on error errMsg
                log "❌ 處理字體設定失敗: " & errMsg
            end try
            
        end tell
    end tell
end run

-- 設定 Bitmap Font 窗口位置
on setupBitmapFontWindow()
    tell application "System Events"
        tell process "ShoeBox"
            try
                set allWindows to every window
                repeat with w in allWindows
                    try
                        set windowPos to position of w
                        set windowSize to size of w
                        set windowX to item 1 of windowPos
                        set windowY to item 2 of windowPos
                        set windowWidth to item 1 of windowSize
                        set windowHeight to item 2 of windowSize
                        
                        -- 根據位置和大小識別 Bitmap Font 窗口
                        if windowX > 400 and windowX < 600 and windowY < 100 and windowWidth > 300 and windowHeight > 200 then
                            set frontmost of w to true
                            delay 0.5
                            log "✅ 找到 Bitmap Font 窗口"
                            exit repeat
                        end if
                    end try
                end repeat
            on error errMsg
                log "❌ 設定 Bitmap Font 窗口失敗: " & errMsg
            end try
        end tell
    end tell
end setupBitmapFontWindow

-- 開啟 Settings 窗口
on openSettingsWindow()
    try
        -- Settings 按鈕位置
        set settingsButtonX to 780
        set settingsButtonY to 320
        
        delay 1
        do shell script "/opt/homebrew/bin/cliclick m:" & settingsButtonX & "," & settingsButtonY
        delay 0.3
        do shell script "/opt/homebrew/bin/cliclick c:" & settingsButtonX & "," & settingsButtonY
        delay 1
        
        log "✅ 已點擊 Settings 按鈕"
        
        -- 等待並設定 Settings 窗口位置
        delay 2
        tell application "System Events"
            tell process "ShoeBox"
                set allWindows to every window
                repeat with w in allWindows
                    try
                        set windowSize to size of w
                        set windowHeight to item 2 of windowSize
                        
                        -- 根據大小識別 Settings 窗口：高度 > 500
                        if windowHeight > 500 then
                            set position of w to {970, 23}
                            set size of w to {350, 600}
                            log "✅ Settings 窗口已定位"
                            exit repeat
                        end if
                    end try
                end repeat
            end tell
        end tell
        
        -- 點擊 Advanced 按鈕
        do shell script "/opt/homebrew/bin/cliclick m:1120,70"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick c:1120,70"
        delay 1
        log "✅ 已點擊 Advanced 按鈕"
        
    on error errMsg
        log "❌ 開啟 Settings 窗口失敗: " & errMsg
    end try
end openSettingsWindow

-- 從 image-heights.json 取得字體高度
on getFontHeight(imageHeightsContent, imageFileName)
    try
        set fontHeight to do shell script "echo " & quoted form of imageHeightsContent & " | jq -r '.heights[] | select(.file == \"" & imageFileName & "\") | .height'"
        return fontHeight
    on error
        log "❌ 無法取得字體高度，使用預設值 37"
        return "37"
    end try
end getFontHeight

-- 更新字體設定
on updateFontSettings(configContent, configKey, fontHeight)
    try
        -- 更新 File Format Loop
        my updateFileFormatLoop(configContent, configKey)
        
        -- 更新 File Format Outer
        my updateFileFormatOuter(configContent, configKey, fontHeight)
        
        -- 更新 Line Height
        my updateLineHeight(fontHeight)
        
    on error errMsg
        log "❌ 更新字體設定失敗: " & errMsg
    end try
end updateFontSettings

-- 更新 File Format Loop
on updateFileFormatLoop(configContent, configKey)
    try
        set fileFormatLoop to do shell script "echo " & quoted form of configContent & " | jq -r '.\"" & configKey & "\".fileFormat.loop'"
        
        -- 點擊並更新 File Format Loop 欄位
        do shell script "/opt/homebrew/bin/cliclick c:1200,200"
        delay 0.5
        my clearAndPasteText(fileFormatLoop)
        
        log "✅ File Format Loop 更新完成"
    on error errMsg
        log "❌ 更新 File Format Loop 失敗: " & errMsg
    end try
end updateFileFormatLoop

-- 更新 File Format Outer
on updateFileFormatOuter(configContent, configKey, fontHeight)
    try
        set fileFormatOuterTemplate to do shell script "echo " & quoted form of configContent & " | jq -r '.\"" & configKey & "\".fileFormat.outer'"
        set fileFormatOuter to do shell script "echo " & quoted form of fileFormatOuterTemplate & " | sed 's/變數/" & fontHeight & "/g'"
        
        -- 點擊並更新 File Format Outer 欄位
        do shell script "/opt/homebrew/bin/cliclick c:1200,235"
        delay 0.5
        my clearAndPasteText(fileFormatOuter)
        
        log "✅ File Format Outer 更新完成"
    on error errMsg
        log "❌ 更新 File Format Outer 失敗: " & errMsg
    end try
end updateFileFormatOuter

-- 更新 Line Height
on updateLineHeight(fontHeight)
    try
        -- 點擊並更新 Line Height 欄位
        do shell script "/opt/homebrew/bin/cliclick c:1165,545"
        delay 0.5
        my clearAndPasteText(fontHeight)
        
        log "✅ Line Height 更新完成"
    on error errMsg
        log "❌ 更新 Line Height 失敗: " & errMsg
    end try
end updateLineHeight

-- 清空文字欄位並貼上新內容
on clearAndPasteText(content)
    tell application "System Events"
        -- 選取全部文字並刪除
        key code 0 using command down -- Cmd+A
        delay 0.3
        key code 51 -- Delete key
        delay 0.5
        
        -- 貼上新內容
        set the clipboard to content
        delay 0.3
        key code 9 using command down -- Cmd+V
        delay 0.5
    end tell
end clearAndPasteText

-- 儲存設定
on saveSettings()
    try
        -- 點擊 Apply 按鈕
        do shell script "/opt/homebrew/bin/cliclick c:1300,645"
        delay 0.5
        
        -- 關閉 Settings 窗口
        do shell script "/opt/homebrew/bin/cliclick c:1330,43"
        delay 0.5
        
        -- 點擊 Save 按鈕
        do shell script "/opt/homebrew/bin/cliclick c:880,318"
        delay 1
        
        log "✅ 設定已儲存"
    on error errMsg
        log "❌ 儲存設定失敗: " & errMsg
    end try
end saveSettings
