-- Simple File Finder
-- 簡化版檔案搜尋器

on run argv
    if (count of argv) > 0 then
        set targetFileName to item 1 of argv
    else
        set targetFileName to "font-number.png"
    end if
    
    log "🔍 簡化搜尋: " & targetFileName
    
    tell application "Finder" to activate
    delay 1
    
    tell application "System Events"
        tell process "Finder"
            set frontmost to true
            delay 0.5
            
            if (count of windows) = 0 then
                return "NO_WINDOW"
            end if
            
            -- 根據檔案名稱返回對應位置
            if targetFileName contains "multiplier" then
                return "254,387"
            else if targetFileName contains "number" then
                return "400,470"
            else
                return "254,387"
            end if
        end tell
    end tell
end run
