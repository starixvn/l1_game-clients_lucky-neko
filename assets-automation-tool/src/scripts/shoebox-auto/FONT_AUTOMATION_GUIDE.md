# Font Automation Guide
# 字體自動化工具使用指南

這個工具集提供了完整的 ShoeBox 字體處理自動化解決方案，支援多種字體類型的批次處理。

## 🚀 快速開始

### 1. 處理 font-multiplier
```bash
cd /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/src/scripts/shoebox-auto
./run-font-automation.sh font-multiplier
```

### 2. 處理 font-number
```bash
cd /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/src/scripts/shoebox-auto
./run-font-automation.sh font-number
```

## 📁 文件結構

### 主要腳本文件
```
shoebox-auto/
├── run-font-automation.sh              # 主要執行器 (新版)
├── position-shoebox-refactored.scpt    # 視窗定位腳本 (重構版)
├── replace-fonts-settings-refactored.scpt # 設定替換腳本 (重構版)
├── font-config-manager.js              # 配置管理器
└── FONT_AUTOMATION_GUIDE.md           # 本說明文件

# 舊版腳本 (保留供參考)
├── run-with-interrupt.sh              # 舊版執行器
├── position-shoebox.scpt              # 舊版視窗定位
└── replace-fonts-settings.scpt        # 舊版設定替換
```

### 配置文件
```
config/
├── font-multiplier-config.json        # font-multiplier 配置
├── font-number-config.json           # font-number 配置 (新)
├── image-heights.json                 # 圖片高度資料
└── shoebox-config/
    ├── font-multiplier.sbx            # Shoebox 配置檔
    ├── font-number.sbx               # font-number Shoebox 配置 (新)
    └── font-win-money.sbx            # 其他字體配置
```

## 🔧 工具功能

### 1. 主要執行器 (`run-font-automation.sh`)
- 🎯 **支援多字體類型**: font-multiplier, font-number
- 🛡️ **中斷保護**: Ctrl+C 安全中斷
- 📊 **詳細日誌**: 每步驟執行狀態
- 🔄 **錯誤處理**: 智能錯誤恢復

```bash
# 使用方法
./run-font-automation.sh [字體類型]

# 範例
./run-font-automation.sh font-multiplier  # 處理 font-multiplier.png
./run-font-automation.sh font-number      # 處理 font-number.png
./run-font-automation.sh --help          # 顯示幫助
```

### 2. 配置管理器 (`font-config-manager.js`)
- ⚙️ **動態配置生成**: 根據圖片高度自動調整
- 🔄 **配置同步**: JSON 和 Shoebox 配置同步更新
- 📏 **高度偵測**: 自動讀取圖片高度並應用

```bash
# 更新所有配置文件
node font-config-manager.js update font-multiplier
node font-config-manager.js update font-number

# 查看字體高度
node font-config-manager.js height font-multiplier

# 列出支援的字體類型
node font-config-manager.js list
```

### 3. 視窗定位腳本 (`position-shoebox-refactored.scpt`)
- 🖥️ **智能視窗管理**: 自動排列 ShoeBox 和 Finder 視窗
- 🎯 **精確拖拽**: 根據字體類型選擇對應圖片位置
- 🔍 **動態偵測**: 自動識別 Bitmap Font 視窗

### 4. 設定替換腳本 (`replace-fonts-settings-refactored.scpt`)
- 📝 **模組化設計**: 函式化處理各個設定步驟
- 🔄 **動態替換**: 根據實際圖片高度調整參數
- 🎛️ **完整設定**: Loop, Outer, LineHeight 全自動配置

## 📊 支援的字體類型

| 字體類型 | 圖片文件 | 輸出文件 | 字符集 | 說明 |
|---------|----------|----------|--------|------|
| font-multiplier | font-multiplier.png | font-multiplier.fnt | 0123456789x., | 倍數顯示字體 |
| font-number | font-number.png | font-number.fnt | 0123456789,. | 數字顯示字體 |

## 🎛️ 配置說明

### 動態高度配置
系統會自動從 `image-heights.json` 讀取每個字體圖片的實際高度，並動態調整以下參數：
- `fileFormat.outer` 中的 `size` 和 `lineHeight`
- `text.lineHeight`
- Shoebox 配置中的對應值

### 字符集配置
每種字體類型都有專屬的字符集配置：
- **font-multiplier**: `0123456789x.,` (包含倍數符號)
- **font-number**: `0123456789,.` (純數字)

## 🚨 故障排除

### 常見問題

1. **腳本執行失敗**
   ```bash
   # 檢查依賴工具
   brew install cliclick
   brew install jq
   
   # 檢查檔案權限
   chmod +x run-font-automation.sh
   chmod +x font-config-manager.js
   ```

2. **找不到圖片文件**
   ```bash
   # 確認圖片存在
   ls -la /Users/jaysonCheng/pentagon/lucky-neko/assets-automation-tool/output/downloads/font-bitmap/
   ```

3. **Shoebox 未回應**
   - 確保 Shoebox 應用程式已正確安裝
   - 手動開啟 Shoebox 確認運作正常
   - 檢查是否有其他自動化工具衝突

4. **配置文件錯誤**
   ```bash
   # 重新生成配置
   node font-config-manager.js update font-multiplier
   node font-config-manager.js update font-number
   ```

### 日誌分析
腳本執行時會產生詳細日誌，包含：
- ✅ 成功操作
- ❌ 錯誤資訊  
- 📁 檔案路徑
- 📏 參數值

## 🔄 工作流程

### 完整處理流程
```
1. 啟動腳本 → 2. 開啟 Finder/Shoebox → 3. 視窗定位 → 4. 拖拽圖片
         ↓
8. 儲存輸出 ← 7. 應用設定 ← 6. 替換配置 ← 5. 讀取配置
```

### 具體步驟說明
1. **啟動**: 執行 `run-font-automation.sh [font-type]`
2. **開啟應用**: 自動開啟 Finder 和 Shoebox
3. **視窗定位**: 智能排列視窗位置
4. **拖拽圖片**: 將指定圖片拖拽到 Shoebox
5. **讀取配置**: 載入對應的字體配置檔案
6. **替換配置**: 動態調整參數 (高度、字符集等)
7. **應用設定**: 將配置寫入 Shoebox Settings
8. **儲存輸出**: 生成 .fnt 和 .png 文件

## 🚀 進階使用

### 新增字體類型
1. 在 `font-config-manager.js` 中新增字體配置
2. 創建對應的配置檔案
3. 更新 `position-shoebox-refactored.scpt` 中的圖片位置
4. 測試執行流程

### 自訂參數
- 修改 `config/*.json` 檔案調整字體參數
- 使用配置管理器重新生成配置
- 根據需要調整 UI 座標位置

## 📝 更新紀錄

- **v2.0** (重構版): 模組化設計，支援多字體類型
- **v1.0** (原始版): 基礎 font-multiplier 處理功能

---

💡 **提示**: 建議在使用前先手動執行一次，確認所有依賴工具正常運作。
