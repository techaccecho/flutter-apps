class FaqContent {
  final String title;
  final String description;
  final List<FaqItem> items;

  const FaqContent({
    required this.title,
    required this.description,
    required this.items,
  });

  factory FaqContent.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items =
        itemsJson
            .map((item) => FaqItem.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort(
            (first, second) => first.sortOrder.compareTo(second.sortOrder),
          );

    return FaqContent(
      title: json['title'] as String? ?? 'FAQ',
      description: json['description'] as String? ?? '',
      items: List<FaqItem>.unmodifiable(items),
    );
  }
}

class FaqItem {
  final int sortOrder;
  final String question;
  final String answer;

  const FaqItem({
    required this.sortOrder,
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }
}
