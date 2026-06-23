import 'package:blog/shared/models/update_blog.dart';

class UpdateThread {
  final String? title;
  final String? content;

  UpdateThread({
    this.title,
    this.content,
  });

  UpdateBlog toUpdateBlog() => UpdateBlog(title: title, content: content);
}
