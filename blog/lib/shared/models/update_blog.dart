class UpdateBlog {
  final String? title;
  final String? content;
  final bool? isDraft;

  UpdateBlog({this.title, this.content, this.isDraft});

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isDraft != null) 'isDraft': isDraft,
    };
  }
}
