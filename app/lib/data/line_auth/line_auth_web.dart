import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import '../../config.dart';
import 'line_auth_result.dart';

const _kStateKey = 'line_login_state';
const _kAnonUidKey = 'line_login_anon_uid';

String get _redirectUri {
  final loc = web.window.location;
  return '${loc.origin}/'; // LINE Developers 後台需登錄相同 callback URL
}

/// 整頁導向 LINE 授權頁（不會返回）。
Future<void> startLineLogin({String? anonymousUid}) async {
  if (kLineChannelId.isEmpty) {
    throw StateError(
        '缺少 LINE_CHANNEL_ID（build 時 --dart-define=LINE_CHANNEL_ID=...）');
  }
  final rand = Random.secure();
  final state =
      base64UrlEncode(List.generate(24, (_) => rand.nextInt(256)));
  web.window.localStorage.setItem(_kStateKey, state);
  if (anonymousUid != null) {
    web.window.localStorage.setItem(_kAnonUidKey, anonymousUid);
  } else {
    web.window.localStorage.removeItem(_kAnonUidKey);
  }

  final url = Uri.https('access.line.me', '/oauth2/v2.1/authorize', {
    'response_type': 'code',
    'client_id': kLineChannelId,
    'redirect_uri': _redirectUri,
    'state': state,
    'scope': 'profile openid',
  });
  web.window.location.href = url.toString();
}

/// App 啟動時呼叫：若網址帶有 LINE 授權回跳參數，完成 custom token 登入。
/// 回傳 [LineRedirectResult.success] 表示已透過 LINE 登入（呼叫端不要再匿名登入）。
Future<LineRedirectResult> maybeHandleLineRedirect() async {
  final uri = Uri.base;
  final code = uri.queryParameters['code'];
  final state = uri.queryParameters['state'];
  if (code == null || state == null) return LineRedirectResult.none;

  final storedState = web.window.localStorage.getItem(_kStateKey);
  web.window.localStorage.removeItem(_kStateKey);
  final anonymousUid = web.window.localStorage.getItem(_kAnonUidKey);
  web.window.localStorage.removeItem(_kAnonUidKey);

  // 清掉網址上的 code/state（無論成功與否）
  web.window.history.replaceState(null, '', '/');

  if (storedState == null || storedState != state) {
    return LineRedirectResult.failed;
  }

  try {
    final res = await http.post(
      Uri.parse('$kAuthWorkerUrl/auth/line/code'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'redirectUri': _redirectUri,
        'anonymousUid': ?anonymousUid,
      }),
    );
    if (res.statusCode != 200) return LineRedirectResult.failed;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final customToken = data['customToken'] as String;
    final profile = data['profile'] as Map<String, dynamic>? ?? const {};

    await FirebaseAuth.instance.signInWithCustomToken(customToken);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // custom token 的 claims 不會寫進 user profile，自己 upsert users/{uid}
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'displayName': profile['displayName'] ?? '我',
      'pictureUrl': profile['pictureUrl'],
      'provider': 'line',
      'starTotal': FieldValue.increment(0), // 不存在時建為 0，存在則不動
    }, SetOptions(merge: true));

    return LineRedirectResult.success;
  } catch (_) {
    return LineRedirectResult.failed;
  }
}
