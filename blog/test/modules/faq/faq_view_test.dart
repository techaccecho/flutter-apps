import 'dart:async';
import 'package:blog/modules/faq/model/faq_content.dart';
import 'package:blog/modules/faq/view/faq_view.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockBlogApiProvider extends Mock implements BlogApiProvider {}

void main() {
  late MockBlogApiProvider mockApiProvider;

  setUp(() {
    mockApiProvider = MockBlogApiProvider();
  });

  group('FaqView Widget Tests', () {
    final testFaq = FaqContent(
      title: 'Community Rules',
      description: 'Please follow the rules below',
      items: [
        FaqItem(
          sortOrder: 1,
          question: 'What is the rule?',
          answer: 'Be nice and helpful.',
        ),
      ],
    );

    final multipleFaq = FaqContent(
      title: 'Help FAQ',
      description: 'Find answers here',
      items: [
        FaqItem(
          sortOrder: 1,
          question: 'Question 1',
          answer: 'Answer 1',
        ),
        FaqItem(
          sortOrder: 2,
          question: 'Question 2',
          answer: 'Answer 2',
        ),
      ],
    );

    testWidgets('displays FAQ content when loaded successfully', (WidgetTester tester) async {
      when(() => mockApiProvider.fetchRulesOfEngagementFaq()).thenAnswer(
        (_) async => ApiResponse<FaqContent>(
          code: 'SUCCESS',
          message: 'Fetched FAQ successfully',
          data: testFaq,
        ),
      );

      await tester.pumpWidget(
        Provider<BlogApiProvider>.value(
          value: mockApiProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: FaqView(),
            ),
          ),
        ),
      );

      // Wait for FutureBuilder to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Community Rules'), findsOneWidget);
      expect(find.text('Please follow the rules below'), findsOneWidget);
      expect(find.text('What is the rule?'), findsOneWidget);

      // ExpansionTile shows answer on tap
      expect(find.text('Be nice and helpful.'), findsNothing);
      await tester.tap(find.text('What is the rule?'));
      await tester.pumpAndSettle();
      expect(find.text('Be nice and helpful.'), findsOneWidget);
    });

    testWidgets('loading state (pending future spinner)', (WidgetTester tester) async {
      final completer = Completer<ApiResponse<FaqContent>>();
      when(() => mockApiProvider.fetchRulesOfEngagementFaq()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        Provider<BlogApiProvider>.value(
          value: mockApiProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: FaqView(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(ApiResponse<FaqContent>(
        code: 'SUCCESS',
        message: 'Success',
        data: testFaq,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Community Rules'), findsOneWidget);
    });

    testWidgets('multiple FAQ items rendering', (WidgetTester tester) async {
      when(() => mockApiProvider.fetchRulesOfEngagementFaq()).thenAnswer(
        (_) async => ApiResponse<FaqContent>(
          code: 'SUCCESS',
          message: 'Success',
          data: multipleFaq,
        ),
      );

      await tester.pumpWidget(
        Provider<BlogApiProvider>.value(
          value: mockApiProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: FaqView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
    });

    testWidgets('retry behaviors (taps retry, updates state, keeps error UI if retry fails again)', (WidgetTester tester) async {
      // First call fails
      when(() => mockApiProvider.fetchRulesOfEngagementFaq())
          .thenAnswer((_) {
            final completer = Completer<ApiResponse<FaqContent>>();
            Future.delayed(const Duration(milliseconds: 1), () {
              completer.completeError(Exception('Fail 1'));
            });
            return completer.future;
          });

      await tester.pumpWidget(
        Provider<BlogApiProvider>.value(
          value: mockApiProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: FaqView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Unable to load the FAQ.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Second call fails again
      when(() => mockApiProvider.fetchRulesOfEngagementFaq())
          .thenAnswer((_) {
            final completer = Completer<ApiResponse<FaqContent>>();
            Future.delayed(const Duration(milliseconds: 1), () {
              completer.completeError(Exception('Fail 2'));
            });
            return completer.future;
          });

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Unable to load the FAQ.'), findsOneWidget);
      verify(() => mockApiProvider.fetchRulesOfEngagementFaq()).called(2);

      // Third call succeeds
      when(() => mockApiProvider.fetchRulesOfEngagementFaq()).thenAnswer(
        (_) async => ApiResponse<FaqContent>(
          code: 'SUCCESS',
          message: 'Success',
          data: testFaq,
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Unable to load the FAQ.'), findsNothing);
      expect(find.text('Community Rules'), findsOneWidget);
      verify(() => mockApiProvider.fetchRulesOfEngagementFaq()).called(1);
    });
  });
}
