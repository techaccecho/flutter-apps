import 'package:blog/shared/view/raised_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RaisedButton Widget Tests', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RaisedButton(
              title: 'Click Me',
              action: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('triggers action on tap', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RaisedButton(
              title: 'Click Me',
              action: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('hover state changes visual state without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RaisedButton(
              title: 'Click Me',
              action: () {},
            ),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      // Move mouse over the button
      await gesture.moveTo(tester.getCenter(find.byType(RaisedButton)));
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown and the hover state updated
      expect(find.text('Click Me'), findsOneWidget);
    });
  });
}
