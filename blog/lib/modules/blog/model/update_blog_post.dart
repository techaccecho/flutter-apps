import 'package:blog/shared/models/update_blog.dart';

class UpdateBlogPost {
  final String? title;
  final String? content;
  final bool? isDraft;

  UpdateBlogPost({this.title, this.content, this.isDraft});

  UpdateBlog toUpdateBlog() =>
      UpdateBlog(title: title, content: content, isDraft: isDraft);
}
