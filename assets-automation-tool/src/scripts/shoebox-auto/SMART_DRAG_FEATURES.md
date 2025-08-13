# 智能拖拽功能說明
# Smart Drag Features Guide

## 🎯 核心功能

### 檔案位置自動偵測
系統提供多種方法來自動找到檔案在螢幕上的位置：

#### 1. AppleScript UI 搜尋
- 直接透過 macOS 的無障礙 API 搜尋 UI 元素
- 可以找到檔案名稱對應的圖示位置
- 支援遞歸搜尋群組和捲動區域

#### 2. 智能網格搜尋
- 動態計算 Finder 視窗的搜尋網格
- 逐點檢查每個位置的元素
- 根據視窗大小自動調整搜尋密度

#### 3. OCR 文字識別 (可選)
- 使用 Tesseract 進行文字識別
- 可以識別螢幕上的檔案名稱文字
- 需要安裝: `brew install tesseract`

#### 4. 視覺搜尋 (規劃中)
- 使用 ImageMagick 進行圖像比對
- 基於模板匹配找到檔案圖示
- 需要安裝: `brew install imagemagick`

## 🛠️ 工具說明

### find-file-position.sh
檔案位置搜尋的核心工具

```bash
# 基本用法
./find-file-position.sh font-multiplier.png

# 指定搜尋方法
./find-file-position.sh font-number.png ui      # UI 搜尋
./find-file-position.sh font-number.png grid    # 網格搜尋
./find-file-position.sh font-number.png auto    # 自動選擇

# 輸出格式: X,Y 座標
# 例如: 220,355
```

**搜尋策略順序 (auto 模式):**
1. AppleScript UI 搜尋 (最準確)
2. 智能網格搜尋 (較可靠)
3. OCR 文字識別 (如果可用)
4. 視覺搜尋 (如果可用)
5. 預設位置 (最後備援)

### smart-drag-tool.sh
智能拖拽執行工具

```bash
# 拖拽到預設位置 (ShoeBox 拖拽區域)
./smart-drag-tool.sh font-multiplier.png

# 拖拽到自訂位置
./smart-drag-tool.sh font-number.png 200 300

# 功能流程:
# 1. 自動搜尋檔案位置
# 2. 準備 Finder 和 ShoeBox 環境
# 3. 執行拖拽操作
# 4. 驗證拖拽結果
```

## 🔧 整合到自動化流程

### 在 position-shoebox-refactored.scpt 中的應用

原本的腳本使用固定座標：
```applescript
-- 舊方法: 固定位置
set imagePosition to {220, 355}
my dragImageToShoeBox(imagePosition)
```

新的智能方法：
```applescript
-- 新方法: 智能搜尋
my smartDragImageToShoeBox(imageFileName)
```

### 備援機制
如果智能拖拽失敗，系統會自動回退到傳統方法：

```applescript
on error errMsg
    log "❌ 智能拖拽失敗，使用備用方法: " & errMsg
    my fallbackDragMethod(imageFileName)
end try
```

## 📊 搜尋準確度比較

| 搜尋方法 | 準確度 | 速度 | 依賴 | 適用場景 |
|---------|--------|------|------|----------|
| UI 搜尋 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | macOS API | 標準 Finder 視窗 |
| 網格搜尋 | ⭐⭐⭐ | ⭐⭐ | cliclick | 檔案位置固定 |
| OCR 識別 | ⭐⭐ | ⭐ | tesseract | 複雜布局 |
| 視覺搜尋 | ⭐⭐⭐⭐ | ⭐ | ImageMagick | 圖示識別 |
| 預設位置 | ⭐ | ⭐⭐⭐⭐⭐ | 無 | 備援方案 |

## 🚀 使用範例

### 場景 1: 標準使用
```bash
cd /path/to/shoebox-auto
./smart-drag-tool.sh font-multiplier.png
```

### 場景 2: 除錯模式
```bash
# 先測試檔案位置搜尋
./find-file-position.sh font-multiplier.png ui

# 如果找到位置 (例如: 245,378)，手動測試拖拽
cliclick m:245,378  # 移動到該位置確認
./smart-drag-tool.sh font-multiplier.png 110 110
```

### 場景 3: 整合到完整流程
```bash
# 使用完整的自動化流程 (推薦)
./run-font-automation.sh font-number
```

## 🎛️ 進階配置

### 自訂搜尋網格
在 `find-file-position.sh` 中調整網格設定：

```bash
# 調整網格密度
set stepX to width / 8   # 增加分母提高密度
set stepY to height / 6  # 減少分母降低密度
```

### 自訂預設位置
在各工具中修改預設位置：

```bash
get_default_position() {
    case "$filename" in
        *"multiplier"*) echo "220,355" ;;
        *"number"*)     echo "350,355" ;;
        *"custom"*)     echo "400,400" ;;  # 新增自訂類型
        *)              echo "220,355" ;;
    esac
}
```

## 🐛 故障排除

### 常見問題

1. **找不到檔案位置**
   - 確認 Finder 視窗已開啟
   - 確認檔案在當前視窗中可見
   - 嘗試切換到圖示檢視模式

2. **拖拽失敗**
   - 檢查 cliclick 是否正確安裝
   - 確認滑鼠位置沒有被其他應用程式阻擋
   - 檢查 ShoeBox 是否正在運行

3. **UI 搜尋失敗**
   - 確認無障礙權限已開啟
   - 重新啟動 Finder
   - 嘗試使用網格搜尋作為備援

### 除錯指令

```bash
# 檢查工具安裝狀態
which cliclick
which tesseract
which magick

# 測試檔案搜尋
./find-file-position.sh font-multiplier.png ui 2>&1 | tee debug.log

# 測試拖拽功能
./smart-drag-tool.sh font-multiplier.png 2>&1 | tee drag-debug.log
```

## 📈 效能最佳化

### 搜尋順序最佳化
根據你的使用環境調整搜尋順序：

```bash
# 如果 UI 搜尋總是成功，可以跳過其他方法
search_auto() {
    if search_with_ui; then
        return 0
    fi
    # 其他方法...
}
```

### 快取機制 (未來功能)
可以實作位置快取，記住常用檔案的位置：

```bash
# 保存到快取
echo "$FILENAME:$position" >> ~/.shoebox_position_cache

# 從快取讀取
cached_position=$(grep "^$FILENAME:" ~/.shoebox_position_cache | cut -d: -f2)
```

---

💡 **提示**: 這些智能拖拽功能大幅提升了自動化的可靠性，即使檔案位置發生變化也能正常工作。

