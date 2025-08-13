-- Enhanced File Finder for Font Bitmap Directory
-- 增強版檔案搜尋器 - 專門針對字體點陣圖目錄

on run argv
    if (count of argv) > 0 then
        set targetFileName to item 1 of argv
    else
        set targetFileName to "font-number.png"
    end if
    
    log "🔍 增強搜尋: " & targetFileName
    
    -- 確保 Finder 在前台
    tell application "Finder" to activate
    delay 1
    
    tell application "System Events"
        tell process "Finder"
            set frontmost to true
            delay 0.5
            
            if (count of windows) = 0 then
                log "❌ 沒有 Finder 視窗"
                return "NO_WINDOW"
            end if
            
            set finderWindow to window 1
            
            -- 方法 1: 深度遞歸搜尋所有可能的 UI 元素
            set foundPosition to my deepSearch(finderWindow, targetFileName)
            if foundPosition is not missing value then
                return foundPosition
            end if
            
            -- 方法 2: 基於已知布局的智能搜尋
            set layoutPosition to my smartLayoutSearch(finderWindow, targetFileName)
            if layoutPosition is not missing value then
                return layoutPosition
            end if
            
            -- 方法 3: 使用座標範圍搜尋
            set rangePosition to my coordinateRangeSearch(targetFileName)
            if rangePosition is not missing value then
                return rangePosition
            end if
            
            -- 方法 4: 返回預設位置
            return my getDefaultPosition(targetFileName)
        end tell
    end tell
end run

-- 深度遞歸搜尋
on deepSearch(parentElement, fileName)
    try
        -- 搜尋所有類型的 UI 元素
        set elementTypes to {"image", "button", "static text", "group", "scroll area"}
        
        repeat with elementType in elementTypes
            try
                set elements to every UI element of parentElement whose role is elementType
                
                repeat with element in elements
                    try
                        set elementName to name of element
                        if elementName is not missing value and elementName contains fileName then
                            set pos to position of element
                            set siz to size of element
                            
                            set centerX to (item 1 of pos) + ((item 1 of siz) / 2)
                            set centerY to (item 2 of pos) + ((item 2 of siz) / 2)
                            
                            log "✅ 深度搜尋找到: " & elementType & " -> " & centerX & "," & centerY
                            return centerX & "," & centerY
                        end if
                        
                        -- 遞歸搜尋子元素
                        if elementType is "group" or elementType is "scroll area" then
                            set subResult to my deepSearch(element, fileName)
                            if subResult is not missing value then
                                return subResult
                            end if
                        end if
                        
                    end try
                end repeat
            end try
        end repeat
        
    on error errMsg
        log "深度搜尋錯誤: " & errMsg
    end try
    
    return missing value
end deepSearch

-- 基於布局的智能搜尋
on smartLayoutSearch(finderWindow, fileName)
    try
        -- 取得視窗資訊
        set winPos to position of finderWindow
        set winSize to size of finderWindow
        set winX to item 1 of winPos
        set winY to item 2 of winPos
        set winWidth to item 1 of winSize
        set winHeight to item 2 of winSize
        
        log "視窗資訊: " & winX & "," & winY & " 大小: " & winWidth & "x" & winHeight
        
        -- 定義檔案圖示的可能位置 (基於 2x2 網格布局)
        set pos1X to winX + 254
        set pos1Y to winY + 387
        set pos2X to winX + 394
        set pos2Y to winY + 387
        set pos3X to winX + 254
        set pos3Y to winY + 503
        set pos4X to winX + 394
        set pos4Y to winY + 503
        
        set iconPositions to {{pos1X, pos1Y}, {pos2X, pos2Y}, {pos3X, pos3Y}, {pos4X, pos4Y}}
        
        -- 逐一檢查每個位置
        repeat with iconPos in iconPositions
            set testX to item 1 of iconPos
            set testY to item 2 of iconPos
            
            log "測試位置: " & testX & "," & testY
            
            -- 移動滑鼠到測試位置並檢查
            do shell script "/opt/homebrew/bin/cliclick m:" & testX & "," & testY
            delay 0.2
            
            -- 檢查該位置的元素
            try
                set elementAtPos to UI element at {testX, testY}
                set elementName to name of elementAtPos
                
                if elementName contains fileName then
                    log "✅ 布局搜尋成功: " & testX & "," & testY
                    return testX & "," & testY
                end if
            end try
        end repeat
        
    on error errMsg
        log "布局搜尋錯誤: " & errMsg
    end try
    
    return missing value
end smartLayoutSearch

-- 座標範圍搜尋
on coordinateRangeSearch(fileName)
    try
        log "🔍 座標範圍搜尋..."
        
        -- 定義搜尋範圍 (基於你提供的圖片)
        set searchRanges to {{220, 350, 280, 420}, {360, 350, 420, 420}, {220, 450, 280, 520}, {360, 450, 420, 520}}
        
        repeat with range in searchRanges
            set startX to item 1 of range
            set startY to item 2 of range
            set endX to item 3 of range
            set endY to item 4 of range
            
            -- 在範圍內進行網格搜尋
            repeat with x from startX to endX by 10
                repeat with y from startY to endY by 10
                    do shell script "/opt/homebrew/bin/cliclick m:" & x & "," & y
                    delay 0.05
                    
                    try
                        tell application "System Events"
                            tell process "Finder"
                                set elementAtPos to UI element at {x, y}
                                set elementName to name of elementAtPos
                                
                                if elementName contains fileName then
                                    log "✅ 範圍搜尋成功: " & x & "," & y
                                    return x & "," & y
                                end if
                            end tell
                        end tell
                    end try
                end repeat
            end repeat
        end repeat
        
    on error errMsg
        log "範圍搜尋錯誤: " & errMsg
    end try
    
    return missing value
end coordinateRangeSearch

-- 取得預設位置
on getDefaultPosition(fileName)
    if fileName contains "multiplier" then
        return "254,387"
    else if fileName contains "number" then
        return "400,470"  -- 你測試的位置
    else
        return "254,387"
    end if
end getDefaultPosition
