import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config.dart';
import 'data/app_repository.dart';
import 'data/fake_app_repository.dart';
import 'data/firebase_app_repository.dart';
import 'data/line_auth/line_auth.dart';
import 'firebase_options.dart';
import 'state/providers.dart';
import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  final AppRepository repo;
  var lineResult = LineRedirectResult.none;
  if (kUseFirebase) {
    assert(
      !DefaultFirebaseOptions.isPlaceholder,
      'firebase_options.dart 還是佔位檔——先執行 flutterfire configure（見 docs/backend-setup.md）',
    );
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // LINE 授權回跳：帶 ?code= 回站時先完成 custom token 登入
    lineResult = await maybeHandleLineRedirect();
    // 訪客先匿名登入；綁定 LINE 時由 Worker 換發 custom token 升級。
    if (lineResult != LineRedirectResult.success &&
        FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    repo = await FirebaseAppRepository.bootstrap();
  } else {
    repo = FakeAppRepository();
  }

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWith((ref) => repo),
        lineRedirectResultProvider.overrideWithValue(lineResult),
      ],
      child: const WhoseTurnApp(),
    ),
  );
}
