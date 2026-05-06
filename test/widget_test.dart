import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_shadow_parry/app/shadow_parry_app.dart';

void main() {
  testWidgets('starts on the title screen and opens battle screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShadowParryApp());

    expect(find.text('Shadow Parry'), findsOneWidget);
    expect(find.text('開始遊戲'), findsOneWidget);
    expect(find.text('操作說明'), findsOneWidget);

    await tester.tap(find.text('開始遊戲'));
    await tester.pumpAndSettle();

    expect(find.text('戰鬥畫面'), findsOneWidget);
    expect(find.text('格擋'), findsOneWidget);
    expect(find.text('閃身'), findsOneWidget);
    expect(find.text('Debug 勝利'), findsOneWidget);
    expect(find.text('Debug 失敗'), findsOneWidget);
  });
}
