import 'dart:async';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/chat_forum/model/create_thread.dart';
import 'package:blog/modules/chat_forum/model/update_thread.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';

class ThreadPaginatedResult {
  final List<Thread> threads;
  final String? nextCursor;
  final bool hasMore;

  ThreadPaginatedResult({
    required this.threads,
    this.nextCursor,
    required this.hasMore,
  });
}

class ChatForumRepository {
  final BlogApiProvider apiProvider;

  ChatForumRepository({required this.apiProvider});

  Future<Thread> createThread(CreateThread request) async {
    final response = await apiProvider.createBlog(request.toCreateBlog());
    return Thread.fromBlog(response.data);
  }

  Future<Thread> getThread(String id) async {
    final response = await apiProvider.fetchBlog(id);
    return Thread.fromBlog(response.data);
  }

  Future<Thread> updateThread({
    required String id,
    required UpdateThread update,
  }) async {
    final response = await apiProvider.updateBlog(
      blogId: id,
      update: update.toUpdateBlog(),
    );
    return Thread.fromBlog(response.data);
  }

  Future<void> deleteThread(String id, {String? reason}) async {
    await apiProvider.deleteBlog(id, reason: reason);
  }

  Future<Thread> softDeleteThread({
    required String id,
    required String reason,
  }) async {
    final response = await apiProvider.softDeleteBlog(id: id, reason: reason);
    return Thread.fromBlog(response.data);
  }

  Future<ThreadPaginatedResult> getThreads({
    String? cursor,
    int? limit,
    String sort = 'desc',
    String? search,
  }) async {
    final response = await apiProvider.fetchBlogsByType(
      type: 'thread',
      cursor: cursor,
      limit: limit,
      sort: sort,
      search: search,
    );
    return ThreadPaginatedResult(
      threads: response.data.map((b) => Thread.fromBlog(b)).toList(),
      nextCursor: response.meta?.nextCursor,
      hasMore: response.meta?.hasMore ?? false,
    );
  }

  Future<Thread> addThreadComment({
    required String id,
    required AddThreadComment request,
  }) async {
    final response = await apiProvider.addComment(
      blogId: id,
      request: request.toAddComment(),
    );
    return Thread.fromBlog(response.data);
  }
}
