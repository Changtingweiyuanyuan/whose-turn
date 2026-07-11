import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whose_turn/app.dart';
import 'package:whose_turn/screens/my_tasks_screen.dart';
import 'package:whose_turn/screens/task_wall_screen.dart';

Widget wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
}

void main() {
  setUpAll(() {
    // 測試環境不打網路抓字體
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App 開啟顯示任務牆與品牌標題', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WhoseTurnApp()));
    expect(find.text('👀 今天換誰？'), findsOneWidget);
    expect(find.text('我要接'), findsWidgets); // 至少一張可接卡片
  });

  testWidgets('任務牆卡片顯示任務、發起人與獎勵', (tester) async {
    await tester.pumpWidget(wrap(const TaskWallScreen()));
    expect(find.text('倒垃圾'), findsOneWidget);
    expect(find.text('發起人：媽媽'), findsWidgets);
    expect(find.text('50 元'), findsOneWidget);
  });

  testWidgets('神秘任務顯示 🎁 ??? 而不是獎勵內容', (tester) async {
    await tester.pumpWidget(wrap(const TaskWallScreen()));
    expect(find.text('🎁 ???'), findsOneWidget);
    expect(find.text('神秘禮物'), findsNothing);
  });

  testWidgets('點「我要接」後卡片變成進行中', (tester) async {
    await tester.pumpWidget(wrap(const TaskWallScreen()));
    await tester.tap(find.text('我要接').first);
    await tester.pumpAndSettle();
    expect(find.text('進行中'), findsWidgets);
  });

  testWidgets('我的任務顯示三個 Tab 與星星進度', (tester) async {
    await tester.pumpWidget(wrap(const MyTasksScreen()));
    // Tab 標籤與卡片狀態標籤都可能出現「進行中」，只驗 Tab 存在
    expect(find.widgetWithText(Tab, '進行中'), findsOneWidget);
    expect(find.text('等待確認'), findsOneWidget);
    expect(find.widgetWithText(Tab, '已完成'), findsOneWidget);
    expect(find.text('3 / 5'), findsOneWidget); // seed：洗碗 3/5
  });
}
