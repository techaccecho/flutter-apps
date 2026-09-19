import 'package:flutter_test/flutter_test.dart';

import 'package:game/main.dart';

void main() {
  testWidgets('Landing page renders the hero title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('PROJECT ECHO'), findsWidgets);
  });
}
