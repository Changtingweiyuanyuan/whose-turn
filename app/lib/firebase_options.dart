// Firebase 專案設定 —— whose-turn-f19dc（正式）。
//
// 由 Firebase Console 的 Web App 設定抄錄（等同 flutterfire configure 的
// web 輸出；本專案 MVP 僅出 Web，一個平台即可）。
// 注意：Web apiKey 是公開的 client 識別碼，不是機密；安全由 Firestore
// security rules 與 Auth 把關。

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  /// 已填入真實專案設定。
  static const bool isPlaceholder = false;

  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'AIzaSyAfXOCy8ZZd9jH9JI7cBZrcLM-cx1JWnLk',
        appId: '1:606077342691:web:ddbd77ccae8098bc9b46d6',
        messagingSenderId: '606077342691',
        projectId: 'whose-turn-f19dc',
        authDomain: 'whose-turn-f19dc.firebaseapp.com',
        storageBucket: 'whose-turn-f19dc.firebasestorage.app',
      );
}
