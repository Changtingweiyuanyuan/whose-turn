import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/app_repository.dart';
import '../data/fake_app_repository.dart';
import '../data/line_auth/line_auth_result.dart';

/// 之後換 Firebase 時只要 override 這個 provider。
final repositoryProvider = ChangeNotifierProvider<AppRepository>(
  (ref) => FakeAppRepository(),
);

/// 這次啟動的 LINE 授權回跳結果；main() 以 override 傳入，
/// HomeShell 首幀讀取後跳成功／失敗 toast。
final lineRedirectResultProvider =
    Provider<LineRedirectResult>((ref) => LineRedirectResult.none);
