import 'package:flutter_test/flutter_test.dart';
import 'package:eat_ate/main.dart';
import 'package:eat_ate/services/store.dart';

void main() {
  testWidgets('app boots with Plan tab', (WidgetTester tester) async {
    await tester.pumpWidget(EatAteApp(
      store: Store(
        geminiKey: null,
        terraKey: null,
      ),
      initialShowReel: false,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Tomorrow'), findsWidgets);
  });
}