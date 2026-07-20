import 'package:web/web.dart' as web;

/// web：刪除帳號後整頁重載，讓 main() 重新以匿名身分開一個全新訪客。
void reloadApp() => web.window.location.reload();
