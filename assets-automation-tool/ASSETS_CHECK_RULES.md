// 我需要一個可擴充性的功能，可以檢查資源是否存在，以及檢查資源是否正確
// 但是每個資料夾的檢查方式不同，所以需要一個可擴充性的功能
// 1. 檢查資源是否存在
// 2. 第一個是 src/assets/resources/symbol-spines 資料夾
// 2. symbol-spines 資料夾 裡面有symbol-0.json ~ symbol-10.json 共13個檔案
// 3. 檢查 symbol-0.json ~ symbol-9.json 裡面 animations 的 "explode", "highlight", "idle" 三個動畫是否存在，不可以拼錯字
// 4. 檢查 symbol-10.json ~ symbol-13.json 裡面 animations 的 "highlight", "idle" 二個動畫是否存在，不可以拼錯字
// 5. symbol.atlas 是否有 symbol.webp 這個字串，以及該資料夾是否有 symbol.webp 這個檔案