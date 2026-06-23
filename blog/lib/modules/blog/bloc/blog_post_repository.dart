import 'dart:async';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';
import 'package:blog/modules/blog/model/update_blog_post.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';

class BlogPostPaginatedResult {
  final List<BlogPost> posts;
  final String? nextCursor;
  final bool hasMore;

  BlogPostPaginatedResult({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });
}

class BlogPostRepository {
  final BlogApiProvider apiProvider;

  BlogPostRepository({
    required this.apiProvider
  });

  Future<BlogPost> createPost(CreateBlogPost request) async {
    final response = await apiProvider.createBlog(request.toCreateBlog());
    return BlogPost.fromBlog(response.data);
  }

  Future<BlogPost> getPost(String id) async {
    final response = await apiProvider.fetchBlog(id);
    return BlogPost.fromBlog(response.data);
  }

  Future<BlogPost> updatePost({required String id, required UpdateBlogPost update}) async {
    final response = await apiProvider.updateBlog(blogId: id, update: update.toUpdateBlog());
    return BlogPost.fromBlog(response.data);
  }

  Future<void> deletePost(String id) async {
    await apiProvider.deleteBlog(id);
  }

  Future<BlogPostPaginatedResult> getPosts({String? cursor}) async {
    final response = await apiProvider.fetchBlogsByType(type: 'post', cursor: cursor);
    return BlogPostPaginatedResult(
      posts: response.data.map((b) => BlogPost.fromBlog(b)).toList(),
      nextCursor: response.meta?.nextCursor,
      hasMore: response.meta?.hasMore ?? false,
    );
  }
}
