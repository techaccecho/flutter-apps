import 'package:blog/modules/faq/model/faq_content.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  late Future<FaqContent> _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = _loadFaq();
  }

  Future<FaqContent> _loadFaq() async {
    final response = await context.read<BlogApiProvider>().fetchRulesOfEngagementFaq();
    return response.data;
  }

  void _retryLoad() {
    setState(() {
      _faqFuture = _loadFaq();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FaqContent>(
      future: _faqFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load the FAQ.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(onPressed: _retryLoad, child: const Text('Retry')),
                ],
              ),
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
                  shape: const Border(),
                  collapsedShape: const Border(),
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
