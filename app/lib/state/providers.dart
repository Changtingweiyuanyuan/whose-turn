import 'package:flutter_riverpod/legacy.dart';

import '../data/app_repository.dart';
import '../data/fake_app_repository.dart';

/// 之後換 Firebase 時只要 override 這個 provider。
final repositoryProvider = ChangeNotifierProvider<AppRepository>(
  (ref) => FakeAppRepository(),
);
