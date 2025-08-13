-- File Position Detector
-- 檔案位置偵測器 - 智能搜尋檔案並取得螢幕座標

-- 取得命令行參數
on run argv
    if (count of argv) > 0 then
        set targetFileName to item 1 of argv
    else
        set targetFileName to "font-multiplier.png"
    end if
    
    log "🔍 搜尋檔案: " & targetFileName
    
    -- 方法 1: 使用 Finder 的 UI 元素搜尋
    set foundPosition to my searchFileInFinder(targetFileName)
    
    if foundPosition is not missing value then
        log "✅ 在 Finder 中找到檔案位置: " & (item 1 of foundPosition) & "," & (item 2 of foundPosition)
        return foundPosition
    else
        -- 方法 2: 使用螢幕截圖和圖像識別 (如果有圖像模板)
        log "⚠️ 在 Finder 中未找到，嘗試其他方法..."
        set templatePosition to my searchByTemplate(targetFileName)
        
        if templatePosition is not missing value then
            log "✅ 透過圖像識別找到位置: " & (item 1 of templatePosition) & "," & (item 2 of templatePosition)
            return templatePosition
        else
            -- 方法 3: 使用預設位置網格搜尋
            log "⚠️ 使用網格搜尋模式..."
            set gridPosition to my searchByGrid(targetFileName)
            return gridPosition
        end if
    end if
end run

-- 方法 1: 在 Finder 中搜尋檔案位置
on searchFileInFinder(fileName)
    try
        tell application "System Events"
            tell process "Finder"
                set frontmost to true
                delay 0.5
                
                -- 取得 Finder 視窗
                if (count of windows) = 0 then
                    log "❌ 沒有開啟的 Finder 視窗"
                    return missing value
                end if
                
                set finderWindow to window 1
                
                -- 嘗試找到檔案圖示
                try
                    -- 方法 1a: 直接搜尋圖示
                    set fileItems to every UI element of finderWindow whose name contains fileName
                    
                    if (count of fileItems) > 0 then
                        set fileItem to item 1 of fileItems
                        set itemPosition to position of fileItem
                        set itemSize to size of fileItem
                        
                        -- 計算圖示中心點
                        set centerX to (item 1 of itemPosition) + ((item 1 of itemSize) / 2)
                        set centerY to (item 2 of itemPosition) + ((item 2 of itemSize) / 2)
                        
                        log "📍 找到檔案圖示: " & fileName & " 位置=" & centerX & "," & centerY
                        return {centerX, centerY}
                    end if
                    
                    -- 方法 1b: 搜尋群組內的項目
                    repeat with groupElement in (every group of finderWindow)
                        try
                            set groupItems to every UI element of groupElement whose name contains fileName
                            if (count of groupItems) > 0 then
                                set fileItem to item 1 of groupItems
                                set itemPosition to position of fileItem
                                set itemSize to size of fileItem
                                
                                set centerX to (item 1 of itemPosition) + ((item 1 of itemSize) / 2)
                                set centerY to (item 2 of itemPosition) + ((item 2 of itemSize) / 2)
                                
                                log "📍 在群組中找到檔案: " & fileName & " 位置=" & centerX & "," & centerY
                                return {centerX, centerY}
                            end if
                        end try
                    end repeat
                    
                    -- 方法 1c: 搜尋捲動區域
                    repeat with scrollArea in (every scroll area of finderWindow)
                        try
                            set scrollItems to every UI element of scrollArea whose name contains fileName
                            if (count of scrollItems) > 0 then
                                set fileItem to item 1 of scrollItems
                                set itemPosition to position of fileItem
                                set itemSize to size of fileItem
                                
                                set centerX to (item 1 of itemPosition) + ((item 1 of itemSize) / 2)
                                set centerY to (item 2 of itemPosition) + ((item 2 of itemSize) / 2)
                                
                                log "📍 在捲動區域找到檔案: " & fileName & " 位置=" & centerX & "," & centerY
                                return {centerX, centerY}
                            end if
                        end try
                    end repeat
                    
                on error errMsg
                    log "❌ Finder UI 搜尋失敗: " & errMsg
                end try
            end tell
        end tell
        
    on error errMsg
        log "❌ Finder 搜尋過程失敗: " & errMsg
    end try
    
    return missing value
end searchFileInFinder

-- 方法 2: 使用圖像識別 (需要 template 圖片)
on searchByTemplate(fileName)
    try
        -- 這裡可以使用 shell script 呼叫圖像識別工具
        -- 例如 ImageMagick 或其他 OCR 工具
        
        -- 暫時返回 missing value，可以後續實作
        log "🔍 圖像識別功能待實作..."
        return missing value
        
    on error errMsg
        log "❌ 圖像識別失敗: " & errMsg
        return missing value
    end try
end searchByTemplate

-- 方法 3: 網格搜尋 - 在常見位置搜尋
on searchByGrid(fileName)
    try
        log "🔍 開始網格搜尋..."
        
        -- 定義搜尋網格 (基於 Finder 視窗的常見檔案位置)
        set searchGrid to {¬
            {120, 320}, {220, 320}, {320, 320}, {420, 320}, ¬
            {120, 355}, {220, 355}, {320, 355}, {420, 355}, ¬
            {120, 390}, {220, 390}, {320, 390}, {420, 390}, ¬
            {120, 425}, {220, 425}, {320, 425}, {420, 425}}
        
        -- 逐一檢查每個網格位置
        repeat with gridPoint in searchGrid
            set testX to item 1 of gridPoint
            set testY to item 2 of gridPoint
            
            -- 移動滑鼠到測試位置
            do shell script "/opt/homebrew/bin/cliclick m:" & testX & "," & testY
            delay 0.2
            
            -- 嘗試取得該位置的檔案資訊
            set foundFile to my checkFileAtPosition(testX, testY)
            
            if foundFile contains fileName then
                log "✅ 網格搜尋找到檔案: " & fileName & " 位置=" & testX & "," & testY
                return {testX, testY}
            end if
        end repeat
        
        log "❌ 網格搜尋未找到檔案: " & fileName
        
        -- 如果都沒找到，返回預設位置
        log "⚠️ 使用預設位置"
        if fileName contains "multiplier" then
            return {220, 355}
        else if fileName contains "number" then
            return {350, 355}
        else
            return {220, 355}
        end if
        
    on error errMsg
        log "❌ 網格搜尋失敗: " & errMsg
        return {220, 355} -- 預設位置
    end try
end searchByGrid

-- 檢查指定位置的檔案名稱
on checkFileAtPosition(x, y)
    try
        tell application "System Events"
            tell process "Finder"
                -- 移動滑鼠到指定位置
                do shell script "/opt/homebrew/bin/cliclick m:" & x & "," & y
                delay 0.1
                
                -- 嘗試取得該位置的 UI 元素
                set elementAtPosition to UI element at {x, y}
                
                if elementAtPosition is not missing value then
                    try
                        set elementName to name of elementAtPosition
                        return elementName
                    on error
                        return ""
                    end try
                else
                    return ""
                end if
            end tell
        end tell
    on error
        return ""
    end try
end checkFileAtPosition

-- 顯示詳細搜尋結果
on displaySearchResult(fileName, position)
    if position is not missing value then
        set x to item 1 of position
        set y to item 2 of position
        
        log "🎯 檔案搜尋結果:"
        log "   檔案名稱: " & fileName
        log "   螢幕座標: (" & x & ", " & y & ")"
        log "   CLI 命令: cliclick m:" & x & "," & y
        log "   可用於拖拽起始位置"
    else
        log "❌ 未找到檔案: " & fileName
    end if
end displaySearchResult

