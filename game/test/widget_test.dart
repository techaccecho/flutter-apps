import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:game/main.dart';

void main() {
  testWidgets('Landing page renders the hero title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Project Echo'), findsWidgets);
  });
}
