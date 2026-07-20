import 'dart:async';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/model/add_blog_post_comment.dart';
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

  BlogPostRepository({required this.apiProvider});

  Future<BlogPost> createPost(CreateBlogPost request) async {
    final response = await apiProvider.createBlog(request.toCreateBlog());
    return BlogPost.fromBlog(response.data);
  }

  Future<BlogPost> getPost(String id) async {
    final response = await apiProvider.fetchBlog(id);
    return BlogPost.fromBlog(response.data);
  }

  Future<BlogPost> updatePost({
    required String id,
    required UpdateBlogPost update,
  }) async {
    final response = await apiProvider.updateBlog(
      blogId: id,
      update: update.toUpdateBlog(),
    );
    return BlogPost.fromBlog(response.data);
  }

  Future<void> deletePost(String id, {String? reason}) async {
    await apiProvider.deleteBlog(id, reason: reason);
  }

  Future<BlogPost> softDeletePost({
    required String id,
    required String reason,
  }) async {
    final response = await apiProvider.softDeleteBlog(id: id, reason: reason);
    return BlogPost.fromBlog(response.data);
  }

  Future<BlogPostPaginatedResult> getPosts({
    String? cursor,
    int? limit,
    String sort = 'desc',
    String? search,
  }) async {
    final response = await apiProvider.fetchBlogsByType(
      type: 'post',
      cursor: cursor,
      limit: limit,
      sort: sort,
      search: search,
    );
    return BlogPostPaginatedResult(
      posts: response.data.map((b) => BlogPost.fromBlog(b)).toList(),
      nextCursor: response.meta?.nextCursor,
      hasMore: response.meta?.hasMore ?? false,
    );
  }

  Future<BlogPost> addBlogPostComment({
    required String id,
    required AddBlogPostComment request,
  }) async {
    final response = await apiProvider.addComment(
      blogId: id,
      request: request.toAddComment(),
    );
    return BlogPost.fromBlog(response.data);
  }
}
