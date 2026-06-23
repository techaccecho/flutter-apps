import 'package:blog/shared/models/update_blog.dart';

class UpdateBlogPost {
  final String? title;
  final String? content;

  UpdateBlogPost({
    this.title,
    this.content,
  });

  UpdateBlog toUpdateBlog() => UpdateBlog(title: title, content: content);
}
