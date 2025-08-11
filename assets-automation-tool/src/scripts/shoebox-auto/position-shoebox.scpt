-- 開啟 Finder 目錄
do shell script "/usr/bin/open /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/output/downloads/font-bitmap"

-- 等待 Finder 開啟
delay 2

-- 開啟 ShoeBox
do shell script "/usr/bin/open -a /Applications/Shoebox.app"

-- 等待 ShoeBox 開啟
delay 4

tell application "System Events"
  -- 智能設定 ShoeBox 視窗
  tell process "ShoeBox"
    set frontmost to true
    try
      -- 找到並移動 ShoeBox 主窗口（有"ShoeBox"名稱的窗口）
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
      -- 滑鼠點擊視窗
      do shell script "/opt/homebrew/bin/cliclick c:110,110"
      delay 0.5
    end try
  end tell
  
  -- 等待一下
  delay 1
  
  -- 設定 Finder 視窗
  tell process "Finder"
    set frontmost to true
    try
      -- 將 Finder 定位到 ShoeBox 下方
      set position of window 1 to {0, 250}
      set size of window 1 to {500, 400}
    end try
  end tell
  
  -- 等待視窗穩定
  delay 1
  
  -- 切換到圖像模式
  tell process "Finder"
    try
      -- 按 Command + 1 切換到圖像檢視
      key code 18 using command down
      delay 0.5
      
      -- 排列方式依照名稱排序 (檢視 -> 排列依據 -> 名稱)
      key code 5 using {command down, option down} -- Cmd+Option+5 或使用選單
      delay 0.3      
    end try
  end tell
  
  -- 等待排序完成
  delay 1
  
  -- 點擊並拖曳 font-multiplier.png
  try
    -- 確保 Finder 窗口在前台
    tell process "Finder"
      set frontmost to true
    end tell
    delay 1
    
    -- 移動滑鼠到 font-multiplier.png 位置並確認
    do shell script "/opt/homebrew/bin/cliclick m:220,375"
    delay 0.8
    
    -- 點擊確認文件位置
    do shell script "/opt/homebrew/bin/cliclick c:220,375"
    delay 0.5
    
    -- 開始拖拉：移動到起始位置並按住滑鼠
    do shell script "/opt/homebrew/bin/cliclick m:220,375"
    delay 0.3
    do shell script "/opt/homebrew/bin/cliclick dd:220,375"
    delay 1
    
    -- 確保 ShoeBox 窗口在前台
    tell process "ShoeBox"
      set frontmost to true
    end tell
    delay 0.5
    
    -- 慢速移動到目標位置 (分段移動)
    do shell script "/opt/homebrew/bin/cliclick dm:165,192"
    delay 0.5
    do shell script "/opt/homebrew/bin/cliclick dm:110,110"
    delay 0.8
    
    -- 結束拖拉 (放開滑鼠)
    do shell script "/opt/homebrew/bin/cliclick du:110,110"
    delay 2
    
    -- 智能設定 Bitmap Font 窗口位置
    delay 2
    try
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
              exit repeat
            end if
          end try
        end repeat
        
        -- 方法2: 如果沒找到，尋找最大的空白窗口（通常是 Bitmap Font）
        if not bitmapMoved then
          set largestWindow to missing value
          set largestSize to 0
          
          repeat with w in allWindows
            try
              set windowName to name of w
              set windowSize to size of w
              set windowArea to (item 1 of windowSize) * (item 2 of windowSize)
              
              -- 空白名稱且面積最大的窗口
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
          end if
        end if
        
        -- 方法3: 如果還是沒找到，設定第一個非ShoeBox窗口
        if not bitmapMoved then
          repeat with w in allWindows
            try
              set windowName to name of w
              if windowName is not "ShoeBox" then
                set position of w to {520, 23}
                set size of w to {400, 300}
                exit repeat
              end if
            end try
          end repeat
        end if
      end tell
    end try
    
    delay 1
    
    -- 點擊 Bitmap Font 窗口中的 Settings 按鈕
    try
      tell process "ShoeBox"
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
        -- Settings 窗口通常比較高（height > 500）且比較窄（width < 400）
        set allWindows to every window
        repeat with w in allWindows
          try
            set windowPos to position of w
            set windowSize to size of w
            set windowX to item 1 of windowPos
            set windowY to item 2 of windowPos
            set windowWidth to item 1 of windowSize
            set windowHeight to item 2 of windowSize
            
            -- 根據大小識別 Settings 窗口：高度 > 500，寬度 < 400
            if windowHeight > 500 and windowWidth < 400 then
              set position of w to {970, 23}  -- 移動到最右邊
              set size of w to {350, 600}     -- 調整大小
              log "✅ Bitmap Font Settings 窗口已定位: " & windowWidth & "x" & windowHeight
              exit repeat
            end if
          end try
        end repeat
        
      end tell
    on error errMsg
      log "❌ 點擊 Settings 按鈕失敗: " & errMsg
    end try
    
    -- 移動滑鼠到 Bitmap Font Settings 窗口準備下一步操作
    do shell script "/opt/homebrew/bin/cliclick m:1100,100"
    delay 0.5

  end try
end tell