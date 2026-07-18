// LINE Web Login（OAuth authorization code flow）。
//
// Web：整頁導向 LINE 授權頁 → 回站帶 ?code= → POST Auth Worker 換
// Firebase custom token → signInWithCustomToken。
// 非 Web 平台為 stub（MVP 僅支援 Web）。
export 'line_auth_result.dart';
export 'line_auth_stub.dart'
    if (dart.library.js_interop) 'line_auth_web.dart';
