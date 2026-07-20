import 'line_auth_result.dart';

/// 非 Web 平台的 stub —— MVP 的 LINE 綁定僅支援 Web。
Future<void> startLineLogin({String? anonymousUid}) async {
  throw UnsupportedError('LINE 綁定目前僅支援 Web');
}

/// 非 Web 沒有 redirect 流程，一律回報未處理。
Future<LineRedirectResult> maybeHandleLineRedirect() async =>
    LineRedirectResult.none;
