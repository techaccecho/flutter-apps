import 'dart:convert';

import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _assetPath = 'assets/data/rules_of_engagement_faq.json';

  Future<_FaqContent> _loadFaq() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    return _FaqContent.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FaqContent>(
      future: _loadFaq(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('Unable to load the FAQ.', style: AppTextStyles.body),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final faq = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(faq.title, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Text(faq.description, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.lg),
            ...faq.items.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  title: Text(item.question, style: AppTextStyles.h3),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(item.answer, style: AppTextStyles.body),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FaqContent {
  final String title;
  final String description;
  final List<_FaqItem> items;

  const _FaqContent({
    required this.title,
    required this.description,
    required this.items,
  });

  factory _FaqContent.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items =
        itemsJson
            .map((item) => _FaqItem.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort(
            (first, second) => first.sortOrder.compareTo(second.sortOrder),
          );

    return _FaqContent(
      title: json['title'] as String? ?? 'FAQ',
      description: json['description'] as String? ?? '',
      items: items,
    );
  }
}

class _FaqItem {
  final int sortOrder;
  final String question;
  final String answer;

  const _FaqItem({
    required this.sortOrder,
    required this.question,
    required this.answer,
  });

  factory _FaqItem.fromJson(Map<String, dynamic> json) {
    return _FaqItem(
      sortOrder: json['sortOrder'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }
}
