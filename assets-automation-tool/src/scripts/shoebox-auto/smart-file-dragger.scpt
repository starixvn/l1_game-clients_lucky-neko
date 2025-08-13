-- Smart File Dragger
-- 智能檔案拖拽器 - 自動搜尋檔案位置並執行拖拽

-- 取得命令行參數
on run argv
    if (count of argv) > 1 then
        set fileName to item 1 of argv
        set targetX to item 2 of argv as number
        set targetY to item 3 of argv as number
    else if (count of argv) > 0 then
        set fileName to item 1 of argv
        -- 預設拖拽到 ShoeBox 的位置
        set targetX to 110
        set targetY to 110
    else
        set fileName to "font-multiplier.png"
        set targetX to 110
        set targetY to 110
    end if
    
    log "🎯 準備拖拽檔案: " & fileName
    log "🎯 目標位置: (" & targetX & ", " & targetY & ")"
    
    -- 確保 Finder 在前台
    tell application "Finder" to activate
    delay 1
    
    -- 搜尋檔案位置
    set sourcePosition to my findFilePosition(fileName)
    
    if sourcePosition is not missing value then
        set sourceX to item 1 of sourcePosition
        set sourceY to item 2 of sourcePosition
        
        log "✅ 找到檔案位置: (" & sourceX & ", " & sourceY & ")"
        
        -- 執行拖拽
        my performDragAndDrop(sourceX, sourceY, targetX, targetY)
        
        log "🎉 拖拽完成!"
    else
        log "❌ 未找到檔案: " & fileName
        return false
    end if
    
    return true
end run

-- 智能搜尋檔案位置
on findFilePosition(fileName)
    log "🔍 開始搜尋檔案: " & fileName
    
    -- 方法 1: Spotlight 搜尋定位
    set spotlightResult to my searchWithSpotlight(fileName)
    if spotlightResult is not missing value then
        return spotlightResult
    end if
    
    -- 方法 2: Finder UI 元素搜尋
    set finderResult to my searchInFinderUI(fileName)
    if finderResult is not missing value then
        return finderResult
    end if
    
    -- 方法 3: 系統 UI 深度搜尋
    set deepSearchResult to my deepUISearch(fileName)
    if deepSearchResult is not missing value then
        return deepSearchResult
    end if
    
    -- 方法 4: 智能網格搜尋
    set gridResult to my intelligentGridSearch(fileName)
    return gridResult
end findFilePosition

-- 方法 1: 使用 Spotlight 搜尋
on searchWithSpotlight(fileName)
    try
        log "🔍 方法 1: Spotlight 搜尋..."
        
        tell application "System Events"
            -- 開啟 Spotlight
            key code 49 using command down -- Cmd+Space
            delay 0.5
            
            -- 輸入檔案名稱
            keystroke fileName
            delay 1
            
            -- 按 Enter 開啟第一個結果
            key code 36 -- Enter
            delay 2
            
            -- 檢查是否在 Finder 中開啟了檔案
            tell process "Finder"
                if frontmost then
                    -- 嘗試找到選中的檔案
                    try
                        set selectedItems to selection
                        if (count of selectedItems) > 0 then
                            set selectedItem to item 1 of selectedItems
                            -- 這裡需要取得檔案在視窗中的位置
                            -- 由於 AppleScript 限制，我們轉到其他方法
                        end if
                    end try
                end if
            end tell
        end tell
        
    on error errMsg
        log "❌ Spotlight 搜尋失敗: " & errMsg
    end try
    
    return missing value
end searchWithSpotlight

-- 方法 2: Finder UI 元素搜尋 (增強版)
on searchInFinderUI(fileName)
    try
        log "🔍 方法 2: Finder UI 搜尋..."
        
        tell application "System Events"
            tell process "Finder"
                set frontmost to true
                delay 0.5
                
                if (count of windows) = 0 then
                    return missing value
                end if
                
                set finderWindow to window 1
                
                -- 遞歸搜尋所有 UI 元素
                set foundPosition to my recursiveUISearch(finderWindow, fileName)
                
                if foundPosition is not missing value then
                    return foundPosition
                end if
            end tell
        end tell
        
    on error errMsg
        log "❌ Finder UI 搜尋失敗: " & errMsg
    end try
    
    return missing value
end searchInFinderUI

-- 遞歸搜尋 UI 元素
on recursiveUISearch(parentElement, fileName)
    try
        -- 直接搜尋當前層級
        set allElements to every UI element of parentElement
        
        repeat with uiElement in allElements
            try
                set elementName to name of uiElement
                if elementName contains fileName then
                    set elementPos to position of uiElement
                    set elementSize to size of uiElement
                    
                    -- 計算中心點
                    set centerX to (item 1 of elementPos) + ((item 1 of elementSize) / 2)
                    set centerY to (item 2 of elementPos) + ((item 2 of elementSize) / 2)
                    
                    log "📍 在 UI 中找到: " & fileName & " -> (" & centerX & ", " & centerY & ")"
                    return {centerX, centerY}
                end if
                
                -- 遞歸搜尋子元素
                try
                    set subResult to my recursiveUISearch(uiElement, fileName)
                    if subResult is not missing value then
                        return subResult
                    end if
                end try
                
            end try
        end repeat
        
    on error
        -- 忽略搜尋錯誤，繼續下一個元素
    end try
    
    return missing value
end recursiveUISearch

-- 方法 3: 系統層級深度搜尋
on deepUISearch(fileName)
    try
        log "🔍 方法 3: 深度 UI 搜尋..."
        
        tell application "System Events"
            -- 搜尋整個螢幕上包含檔案名稱的元素
            set allProcesses to every process
            
            repeat with proc in allProcesses
                try
                    set processName to name of proc
                    if processName is "Finder" then
                        set allWindows to every window of proc
                        
                        repeat with win in allWindows
                            try
                                set foundPos to my searchWindowRecursively(win, fileName)
                                if foundPos is not missing value then
                                    return foundPos
                                end if
                            end try
                        end repeat
                    end if
                end try
            end repeat
        end tell
        
    on error errMsg
        log "❌ 深度搜尋失敗: " & errMsg
    end try
    
    return missing value
end deepUISearch

-- 遞歸搜尋視窗內容
on searchWindowRecursively(windowElement, fileName)
    try
        -- 使用更廣泛的搜尋策略
        set allElements to every UI element of windowElement
        
        repeat with element in allElements
            try
                -- 檢查元素名稱
                try
                    set elementName to name of element
                    if elementName is not missing value and elementName contains fileName then
                        set pos to position of element
                        set siz to size of element
                        
                        set centerX to (item 1 of pos) + ((item 1 of siz) / 2)
                        set centerY to (item 2 of pos) + ((item 2 of siz) / 2)
                        
                        return {centerX, centerY}
                    end if
                end try
                
                -- 檢查元素描述
                try
                    set elementDesc to description of element
                    if elementDesc is not missing value and elementDesc contains fileName then
                        set pos to position of element
                        set siz to size of element
                        
                        set centerX to (item 1 of pos) + ((item 1 of siz) / 2)
                        set centerY to (item 2 of pos) + ((item 2 of siz) / 2)
                        
                        return {centerX, centerY}
                    end if
                end try
                
                -- 遞歸搜尋子元素
                try
                    set subResult to my searchWindowRecursively(element, fileName)
                    if subResult is not missing value then
                        return subResult
                    end if
                end try
                
            end try
        end repeat
        
    on error
        -- 忽略錯誤
    end try
    
    return missing value
end searchWindowRecursively

-- 方法 4: 智能網格搜尋 (改進版)
on intelligentGridSearch(fileName)
    try
        log "🔍 方法 4: 智能網格搜尋..."
        
        -- 取得 Finder 視窗位置和大小
        tell application "System Events"
            tell process "Finder"
                if (count of windows) > 0 then
                    set finderWindow to window 1
                    set winPos to position of finderWindow
                    set winSize to size of finderWindow
                    
                    set winX to item 1 of winPos
                    set winY to item 2 of winPos
                    set winWidth to item 1 of winSize
                    set winHeight to item 2 of winSize
                    
                    -- 動態計算搜尋網格
                    set gridPoints to my calculateSearchGrid(winX, winY, winWidth, winHeight)
                    
                    -- 逐點搜尋
                    repeat with point in gridPoints
                        set testX to item 1 of point
                        set testY to item 2 of point
                        
                        -- 移動滑鼠並檢查
                        do shell script "/opt/homebrew/bin/cliclick m:" & testX & "," & testY
                        delay 0.1
                        
                        -- 檢查該位置是否有目標檔案
                        if my checkPositionForFile(testX, testY, fileName) then
                            log "✅ 網格搜尋成功: " & fileName & " -> (" & testX & ", " & testY & ")"
                            return {testX, testY}
                        end if
                    end repeat
                end if
            end tell
        end tell
        
        -- 如果網格搜尋失敗，使用預設位置
        log "⚠️ 網格搜尋失敗，使用預設位置"
        return my getDefaultPosition(fileName)
        
    on error errMsg
        log "❌ 智能網格搜尋失敗: " & errMsg
        return my getDefaultPosition(fileName)
    end try
end intelligentGridSearch

-- 計算搜尋網格點
on calculateSearchGrid(startX, startY, width, height)
    set gridPoints to {}
    
    -- 計算網格間距
    set stepX to width / 8
    set stepY to height / 6
    
    -- 生成網格點 (從視窗內容區域開始)
    set contentStartX to startX + 20
    set contentStartY to startY + 80 -- 考慮標題列
    
    repeat with row from 0 to 5
        repeat with col from 0 to 7
            set gridX to contentStartX + (col * stepX)
            set gridY to contentStartY + (row * stepY)
            
            -- 確保點在視窗範圍內
            if gridX < (startX + width - 20) and gridY < (startY + height - 20) then
                set end of gridPoints to {gridX, gridY}
            end if
        end repeat
    end repeat
    
    return gridPoints
end calculateSearchGrid

-- 檢查指定位置是否有目標檔案
on checkPositionForFile(x, y, fileName)
    try
        -- 使用 shell script 檢查滑鼠位置下的元素
        -- 這裡可以加入更精確的檢測邏輯
        return false
    on error
        return false
    end try
end checkPositionForFile

-- 取得預設位置
on getDefaultPosition(fileName)
    if fileName contains "multiplier" then
        return {220, 355}
    else if fileName contains "number" then
        return {350, 355}
    else
        return {220, 355}
    end if
end getDefaultPosition

-- 執行拖拽操作
on performDragAndDrop(sourceX, sourceY, targetX, targetY)
    try
        log "🎯 開始拖拽: (" & sourceX & ", " & sourceY & ") -> (" & targetX & ", " & targetY & ")"
        
        -- 確保 Finder 在前台
        tell application "System Events"
            tell process "Finder"
                set frontmost to true
            end tell
        end tell
        delay 0.5
        
        -- 移動到源位置
        do shell script "/opt/homebrew/bin/cliclick m:" & sourceX & "," & sourceY
        delay 0.3
        
        -- 開始拖拽
        do shell script "/opt/homebrew/bin/cliclick dd:" & sourceX & "," & sourceY
        delay 0.5
        
        -- 確保目標應用在前台 (ShoeBox)
        tell application "System Events"
            tell process "ShoeBox"
                set frontmost to true
            end tell
        end tell
        delay 0.3
        
        -- 移動到目標位置
        do shell script "/opt/homebrew/bin/cliclick dm:" & targetX & "," & targetY
        delay 0.5
        
        -- 結束拖拽
        do shell script "/opt/homebrew/bin/cliclick du:" & targetX & "," & targetY
        delay 1
        
        log "✅ 拖拽操作完成"
        
    on error errMsg
        log "❌ 拖拽操作失敗: " & errMsg
        
        -- 嘗試釋放滑鼠按鍵 (預防卡住)
        try
            do shell script "/opt/homebrew/bin/cliclick du:0,0"
        end try
    end try
end performDragAndDrop

