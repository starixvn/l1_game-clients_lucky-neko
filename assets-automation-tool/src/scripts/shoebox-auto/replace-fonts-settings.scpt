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
        
        -- 滑鼠移動到 File Format Outer 位置 1200,235
        do shell script "/opt/homebrew/bin/cliclick m:1200,235"
        delay 0.5
        -- 使用 jq 解析 JSON 並提取 font-multiplier.fileFormat.outer 的值
        set fileFormatOuter to do shell script "echo " & quoted form of configContent & " | jq -r '.\"font-multiplier\".fileFormat.outer'"
        log "✅ 成功讀取 File Format Outer 設定: " & fileFormatOuter

        -- 滑鼠移動到 File Format Outer 位置 1200,235
        do shell script "/opt/homebrew/bin/cliclick m:1200,235"
        delay 0.5

        -- 滑鼠點擊 File Format Outer 文字編輯視窗並選取所有文字
        do shell script "/opt/homebrew/bin/cliclick c:1200,235"
        delay 0.5
        -- 選取全部文字 (Cmd+A) 然後刪除
        key code 0 using command down  -- Cmd+A
        delay 0.3
        key code 51  -- Delete key
        delay 0.5

        -- 輸入新的 File Format Outer 文字
        -- 先讀取 image-heights.json 找到 font-multiplier 的 height 值
        set imageHeightsPath to "/Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/config/image-heights.json"
        set imageHeightsContent to do shell script "cat " & quoted form of imageHeightsPath
        
        -- 使用 jq 找到 font-multiplier.png 的 height 值
        set fontMultiplierHeight to do shell script "echo " & quoted form of imageHeightsContent & " | jq -r '.heights[] | select(.file == \"font-multiplier.png\") | .height'"
        log "✅ 從 image-heights.json 讀取到 font-multiplier height: " & fontMultiplierHeight
        
        -- 取得原始的 fileFormat.outer 模板
        set fileFormatOuterTemplate to do shell script "echo " & quoted form of configContent & " | jq -r '.\"font-multiplier\".fileFormat.outer'"
        
        -- 使用 sed 將模板中的 "變數" 替換為實際的 height 值
        set fileFormatOuter to do shell script "echo " & quoted form of fileFormatOuterTemplate & " | sed 's/變數/" & fontMultiplierHeight & "/g'"
        log "✅ 成功處理 File Format Outer 設定: " & fileFormatOuter
        
        -- 將處理好的 fileFormatOuter 內容設定到剪貼簿並貼上
        set the clipboard to fileFormatOuter
        delay 0.3
        key code 9 using command down  -- Cmd+V
        delay 0.5
        
        log "✅ 已成功更新 File Format Outer 設定"

        -- 使用 sed 將  1165,545 txt Line Height 改為 fontMultiplierHeight
        do shell script "/opt/homebrew/bin/cliclick m:1165,545"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick c:1165,545"
        delay 0.5
        -- 選取全部文字 (Cmd+A) 然後刪除
        key code 0 using command down  -- Cmd+A
        delay 0.3
        key code 51  -- Delete key
        delay 0.5
        set the clipboard to fontMultiplierHeight
        delay 0.3
        key code 9 using command down  -- Cmd+V
        delay 0.5
        log "✅ 已成功更新 txt Line Height 設定"


        -- 點擊 Apply 按鈕
        do shell script "/opt/homebrew/bin/cliclick m:1300,645"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick c:1300,645"
        delay 0.5
        -- 點擊 Apply X 關閉按鈕
        do shell script "/opt/homebrew/bin/cliclick m:1330,43"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick c:1330,43"
        delay 0.5
        
        -- 點擊 Save 按鈕
        do shell script "/opt/homebrew/bin/cliclick m:880,318"
        delay 0.5
        do shell script "/opt/homebrew/bin/cliclick c:880,318"
        delay 1
        log "✅ 已點擊 Apply + Save 按鈕"

    on error errMsg
        log "❌ 讀取或設定 File Format 失敗: " & errMsg
    end try
  end tell
end tell
