class BlogPost {
  final String id;
  final String title;
  final String author;
  final String date;
  final String excerpt;
  final int comments;

  BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.excerpt,
    required this.comments,
  });
}