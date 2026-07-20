import 'package:flutter_web_plugins/url_strategy.dart';

/// web：改用 path URL（無 #），/j/邀請碼、/task/id 深連結才會進 router。
void configureUrlStrategy() => usePathUrlStrategy();
