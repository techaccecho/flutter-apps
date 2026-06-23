class UpdateBlog {
  final String? title;
  final String? content;

  UpdateBlog({this.title, this.content});

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}
