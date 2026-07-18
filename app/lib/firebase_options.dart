// ⚠️ 佔位檔 —— 尚未連接真實 Firebase 專案。
//
// 建立 Firebase 專案後，在 app/ 目錄執行：
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// FlutterFire CLI 會用真實金鑰「覆寫」本檔。
// 在那之前 kUseFirebase 保持 false，App 跑 FakeAppRepository（demo 模式），
// 本檔不會被真正使用。

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  /// flutterfire configure 覆寫前的哨兵值；bootstrap 會檢查並擋下。
  static const bool isPlaceholder = true;

  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'PLACEHOLDER',
        appId: 'PLACEHOLDER',
        messagingSenderId: 'PLACEHOLDER',
        projectId: 'PLACEHOLDER',
      );
}
