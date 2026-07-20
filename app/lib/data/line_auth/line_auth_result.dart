/// LINE 授權回跳的處理結果，app 啟動後用來決定要不要跳 toast。
enum LineRedirectResult {
  /// 這次啟動不是 LINE 回跳（網址沒有 code/state）。
  none,

  /// 已完成 custom token 登入，帳號綁定成功。
  success,

  /// 有回跳參數但綁定失敗（state 不符、Worker 錯誤、網路失敗）。
  failed,
}
