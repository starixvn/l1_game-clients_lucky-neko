-- Replace Fonts Settings Script
-- 替換字體設定腳本

tell application "System Events"
  tell process "ShoeBox"
    set frontmost to true
    delay 0.5

    -- 使用 shoebox fonts config 設定檔案
    do shell script "open -a 'Shoebox' /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/config/shoebox-config/font-multiplier.sbx"
    delay 1

    -- 點擊 Bitmap Font 窗口中的 Settings 按鈕
    try
        -- 找到 Bitmap Font 窗口（位置在 {520, 25} 附近的窗口）
        set bitmapWindow to missing value
        set allWindows to every window
        
        repeat with w in allWindows
          try
            set windowPos to position of w
            set windowSize to size of w
            set windowName to name of w
            set windowX to item 1 of windowPos
            set windowY to item 2 of windowPos
            set windowWidth to item 1 of windowSize
            set windowHeight to item 2 of windowSize
            
            -- 根據位置和大小識別 Bitmap Font 窗口
            -- 通常在 {520, 25} 位置，大小約 {416, 313}
            if windowX > 400 and windowX < 600 and windowY < 100 and windowWidth > 300 and windowHeight > 200 then
              set bitmapWindow to w
              set frontmost of w to true
              delay 0.5
              log "找到 Bitmap Font 窗口: 位置=" & windowX & "," & windowY & " 大小=" & windowWidth & "x" & windowHeight
              exit repeat
            end if
          end try
        end repeat
        
        -- 如果找到 Bitmap Font 窗口，動態計算 Settings 按鈕位置
        if bitmapWindow is not missing value then
          set windowPos to position of bitmapWindow
          set windowSize to size of bitmapWindow
          set windowX to item 1 of windowPos
          set windowY to item 2 of windowPos
          set windowWidth to item 1 of windowSize
          set windowHeight to item 2 of windowSize
          
          -- Settings 按鈕位置修正為 780,320
          set settingsButtonX to 780
          set settingsButtonY to 320
          
          log "Bitmap Font 窗口位置: " & windowX & "," & windowY
          log "Settings 按鈕位置: " & settingsButtonX & "," & settingsButtonY
          
          delay 1
          do shell script "/opt/homebrew/bin/cliclick m:" & settingsButtonX & "," & settingsButtonY
          delay 0.3
          do shell script "/opt/homebrew/bin/cliclick c:" & settingsButtonX & "," & settingsButtonY
          delay 1
          
          log "✅ 已點擊 Settings 按鈕"
          
        else
          log "❌ 未找到 Bitmap Font 窗口"
        end if
        
        -- 等待 Bitmap Font Settings 窗口出現
        delay 2
        
        -- 檢查 Settings 窗口是否已出現並移動位置
        -- Settings 窗口通常比較高（height > 500)
        set allWindows to every window
        repeat with w in allWindows
          try
            set windowPos to position of w
            set windowSize to size of w
            set windowX to item 1 of windowPos
            set windowY to item 2 of windowPos
            set windowWidth to item 1 of windowSize
            set windowHeight to item 2 of windowSize
            
            -- 根據大小識別 Settings 窗口：高度 > 500
            if windowHeight > 500
              set position of w to {970, 23}  -- 移動到最右邊
              set size of w to {350, 600}     -- 調整大小
              log "✅ Bitmap Font Settings 窗口已定位: " & windowWidth & "x" & windowHeight
              exit repeat
            end if
          end try
        end repeat
        
    on error errMsg
      log "❌ 點擊 Settings 按鈕失敗: " & errMsg
    end try
    
    -- 移動滑鼠到 Bitmap Font Settings 窗口內部準備下一步操作
    -- 點擊 Advanced 按鈕
    do shell script "/opt/homebrew/bin/cliclick m:1120,70"
    delay 0.5
    do shell script "/opt/homebrew/bin/cliclick c:1120,70"
    delay 1
    log "✅ 已點擊 Advanced 按鈕"

    -- 讀取配置文件中的 File Format Loop 設定
    set configFilePath to "/Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/config/font-multiplier-config.json"
    try
        set configContent to do shell script "cat " & quoted form of configFilePath
        -- 使用 jq 解析 JSON 並提取 font-multiplier.fileFormat.loop 的值
        set fileFormatLoop to do shell script "echo " & quoted form of configContent & " | jq -r '.\"font-multiplier\".fileFormat.loop'"
        log "✅ 成功讀取 File Format Loop 設定: " & fileFormatLoop
        
        -- 滑鼠移動到 File Format Loop 位置
        do shell script "/opt/homebrew/bin/cliclick m:1200,200"
        delay 0.5
        
        -- 滑鼠點擊 File Format Loop 文字編輯視窗並選取所有文字
        do shell script "/opt/homebrew/bin/cliclick c:1200,200"
        delay 0.5
        
        -- 選取全部文字 (Cmd+A) 然後刪除
        key code 0 using command down  -- Cmd+A
        delay 0.3
        key code 51  -- Delete key
        delay 0.5
        
        -- 輸入新的 File Format Loop 文字
        set the clipboard to fileFormatLoop
        delay 0.3
        key code 9 using command down  -- Cmd+V
        delay 0.5
        
        log "✅ 已成功更新 File Format Loop 設定"
        
    on error errMsg
        log "❌ 讀取或設定 File Format Loop 失敗: " & errMsg
    end try

  end tell
end tell
