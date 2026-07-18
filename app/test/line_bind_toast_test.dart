import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whose_turn/app.dart';
import 'package:whose_turn/data/line_auth/line_auth_result.dart';
import 'package:whose_turn/state/providers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpApp(WidgetTester tester, LineRedirectResult result) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [lineRedirectResultProvider.overrideWithValue(result)],
        child: const WhoseTurnApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900)); // 延遲 show
    await tester.pump(const Duration(milliseconds: 300)); // toast 進場動畫
  }

  testWidgets('LINE 綁定成功顯示成功 toast', (tester) async {
    await pumpApp(tester, LineRedirectResult.success);
    expect(find.text('LINE 綁定成功！星星與紀錄會永久保存'), findsOneWidget);
  });

  testWidgets('LINE 綁定失敗顯示失敗 toast', (tester) async {
    await pumpApp(tester, LineRedirectResult.failed);
    expect(find.text('LINE 綁定失敗，請再試一次'), findsOneWidget);
  });

  testWidgets('非回跳啟動不顯示 toast', (tester) async {
    await pumpApp(tester, LineRedirectResult.none);
    expect(find.text('LINE 綁定成功！星星與紀錄會永久保存'), findsNothing);
    expect(find.text('LINE 綁定失敗，請再試一次'), findsNothing);
  });
}
