import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';
import 'package:blog/modules/blog/model/update_blog_post.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';
import 'package:blog/modules/chat_forum/model/create_thread.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/chat_forum/model/update_thread.dart';
import 'package:blog/shared/models/blog.dart';
import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/reaction.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final author = UserPreview(
    id: 'user_1',
    email: 'user@example.com',
    alias: 'author',
    firstName: 'First',
    lastName: 'Last',
  );
  final reaction = Reaction(
    id: 'reaction_1',
    user: author,
    code: 'like',
    createdAt: DateTime.utc(2026, 7, 19, 10),
  );
  final engagement = Engagement(
    views: 1,
    comments: 2,
    attachments: 3,
    reactions: 4,
  );

  Blog createBlog({String type = 'post'}) {
    return Blog(
      id: 'blog_1',
      author: author,
      type: type,
      title: 'Title',
      content: 'Content',
      priority: 5,
      isDraft: false,
      isPinned: true,
      isLocked: false,
      participants: [author],
      comments: [],
      attachments: [],
      viewers: [author],
      reactions: [reaction],
      engagement: engagement,
      createdAt: DateTime.utc(2026, 7, 19, 9),
      updatedAt: DateTime.utc(2026, 7, 19, 10),
      deletedAt: DateTime.utc(2026, 7, 19, 11),
    );
  }

  group('model mapping', () {
    test(
      'BlogPost.fromBlog maps scalar fields, author, lists, engagement, and timestamps',
      () {
        final post = BlogPost.fromBlog(createBlog());

        expect(post.id, 'blog_1');
        expect(post.author.id, 'user_1');
        expect(post.title, 'Title');
        expect(post.priority, 5);
        expect(post.isPinned, isTrue);
        expect(post.viewers.single.id, 'user_1');
        expect(post.reactions.single.id, 'reaction_1');
        expect(post.engagement.reactions, 4);
        expect(post.createdAt, DateTime.utc(2026, 7, 19, 9));
        expect(post.updatedAt, DateTime.utc(2026, 7, 19, 10));
        expect(post.deletedAt, DateTime.utc(2026, 7, 19, 11));
        expect(post.isAdminRemoved, isTrue);
      },
    );

    test('Thread.fromBlog maps participants and shared blog fields', () {
      final thread = Thread.fromBlog(createBlog(type: 'thread'));

      expect(thread.id, 'blog_1');
      expect(thread.author.alias, 'author');
      expect(thread.participants.single.id, 'user_1');
      expect(thread.reactions.single.code, 'like');
      expect(thread.engagement.views, 1);
      expect(thread.isAdminRemoved, isTrue);
    });

    test('request DTO conversions set expected type and payload fields', () {
      final publishDate = DateTime.utc(2026, 7, 19);
      final createPost = CreateBlogPost(
        authorId: 'user_1',
        title: 'Post',
        content: 'Body',
        isDraft: true,
        createdAt: publishDate,
      ).toCreateBlog();
      final updatePost = UpdateBlogPost(
        title: 'Updated',
        content: 'Changed',
        isDraft: false,
      ).toUpdateBlog();
      final createThread = CreateThread(
        authorId: 'user_2',
        title: 'Thread',
        content: 'Question',
      ).toCreateBlog();
      final updateThread = UpdateThread(
        title: 'Retitled',
        content: 'Edited',
      ).toUpdateBlog();
      final addComment = AddThreadComment(
        authorId: 'user_3',
        content: 'Reply',
      ).toAddComment();

      expect(createPost.type, 'post');
      expect(createPost.isDraft, isTrue);
      expect(createPost.createdAt, publishDate);
      expect(updatePost.title, 'Updated');
      expect(updatePost.isDraft, isFalse);
      expect(createThread.type, 'thread');
      expect(createThread.isDraft, isFalse);
      expect(updateThread.content, 'Edited');
      expect(addComment.authorId, 'user_3');
      expect(addComment.content, 'Reply');
    });

    test('Blog and Comment toJson serialize reactions from reactions list', () {
      final blogJson = createBlog().toJson();
      final commentJson = Comment(
        id: 'comment_1',
        author: author,
        content: 'Comment',
        replies: const [],
        attachments: const [],
        viewers: const [],
        reactions: [reaction],
        engagement: engagement,
        createdAt: DateTime.utc(2026, 7, 19),
      ).toJson();

      expect(blogJson['attachments'], isEmpty);
      expect(blogJson['reactions'], hasLength(1));
      expect((blogJson['reactions'] as List).single['id'], 'reaction_1');
      expect(commentJson['attachments'], isEmpty);
      expect(commentJson['reactions'], hasLength(1));
      expect((commentJson['reactions'] as List).single['id'], 'reaction_1');
    });

    group('User model tests', () {
      test('User.fromJson maps all fields correctly', () {
        final json = {
          'id': 'user_123',
          'authId': 'auth_123',
          'email': 'user@example.com',
          'alias': 'testalias',
          'firstName': 'John',
          'lastName': 'Doe',
          'dateOfBirth': '1990-01-01',
          'bio': 'A software developer.',
          'role': 'admin',
          'isLocked': false,
          'avatar': {
            'id': 'attach_1',
            'blogId': 'blog_1',
            'type': 'image',
            'url': 'https://example.com/avatar.png',
            'createdAt': '2026-07-19T10:00:00Z',
          },
          'createdAt': '2026-07-19T09:00:00Z',
          'updatedAt': '2026-07-19T10:00:00Z',
          'lastActivityAt': '2026-07-19T11:00:00Z',
        };

        final user = User.fromJson(json);

        expect(user.id, 'user_123');
        expect(user.authId, 'auth_123');
        expect(user.email, 'user@example.com');
        expect(user.alias, 'testalias');
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.dateOfBirth, '1990-01-01');
        expect(user.bio, 'A software developer.');
        expect(user.role, 'admin');
        expect(user.isLocked, isFalse);
        expect(user.avatar?.url, 'https://example.com/avatar.png');
        expect(user.createdAt, DateTime.parse('2026-07-19T09:00:00Z'));
        expect(user.updatedAt, DateTime.parse('2026-07-19T10:00:00Z'));
        expect(user.lastActivityAt, DateTime.parse('2026-07-19T11:00:00Z'));
      });

      test('User.displayName fallback logic works', () {
        // Alias is preferred
        var user = User(
          id: '1', authId: 'a', email: 'e', alias: 'alias_val',
          firstName: 'first_val', lastName: 'last_val', role: 'u',
          isLocked: false, createdAt: DateTime.now(), lastActivityAt: DateTime.now(),
        );
        expect(user.displayName, 'alias_val');

        // FirstName is next
        user = User(
          id: '1', authId: 'a', email: 'e', alias: null,
          firstName: 'first_val', lastName: 'last_val', role: 'u',
          isLocked: false, createdAt: DateTime.now(), lastActivityAt: DateTime.now(),
        );
        expect(user.displayName, 'first_val');

        // LastName is next
        user = User(
          id: '1', authId: 'a', email: 'e', alias: null,
          firstName: null, lastName: 'last_val', role: 'u',
          isLocked: false, createdAt: DateTime.now(), lastActivityAt: DateTime.now(),
        );
        expect(user.displayName, 'last_val');

        // Email is fallback
        user = User(
          id: '1', authId: 'a', email: 'email_val', alias: null,
          firstName: null, lastName: null, role: 'u',
          isLocked: false, createdAt: DateTime.now(), lastActivityAt: DateTime.now(),
        );
        expect(user.displayName, 'email_val');
      });

      test('User.displayCreatedAt formats date correctly', () {
        final date = DateTime.utc(2026, 7, 19, 14, 30);
        final user = User(
          id: '1', authId: 'a', email: 'e', role: 'u', isLocked: false,
          createdAt: date, lastActivityAt: DateTime.now(),
        );
        expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(user.displayCreatedAt), isTrue);
      });
    });

    group('UserPreview model tests', () {
      test('UserPreview.fromJson maps correctly', () {
        final json = {
          'id': 'user_123',
          'email': 'user@example.com',
          'alias': 'testalias',
          'firstName': 'John',
          'lastName': 'Doe',
        };

        final preview = UserPreview.fromJson(json);

        expect(preview.id, 'user_123');
        expect(preview.email, 'user@example.com');
        expect(preview.alias, 'testalias');
        expect(preview.firstName, 'John');
        expect(preview.lastName, 'Doe');
      });

      test('UserPreview.fromUser maps correctly', () {
        final user = User(
          id: 'user_123',
          authId: 'auth_123',
          email: 'user@example.com',
          alias: 'testalias',
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isLocked: false,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );

        final preview = UserPreview.fromUser(user);

        expect(preview.id, 'user_123');
        expect(preview.email, 'user@example.com');
        expect(preview.alias, 'testalias');
        expect(preview.firstName, 'John');
        expect(preview.lastName, 'Doe');
      });

      test('UserPreview.toJson serializes correctly', () {
        final preview = UserPreview(
          id: 'user_123',
          email: 'user@example.com',
          alias: 'testalias',
          firstName: 'John',
          lastName: 'Doe',
        );

        final json = preview.toJson();

        expect(json['id'], 'user_123');
        expect(json['email'], 'user@example.com');
        expect(json['alias'], 'testalias');
        expect(json['firstName'], 'John');
        expect(json['lastName'], 'Doe');
      });

      test('UserPreview.displayName fallback logic works', () {
        // Alias is preferred
        var preview = UserPreview(id: '1', email: 'e', alias: 'alias_val', firstName: 'first_val', lastName: 'last_val');
        expect(preview.displayName, 'alias_val');

        // FirstName is next
        preview = UserPreview(id: '1', email: 'e', alias: null, firstName: 'first_val', lastName: 'last_val');
        expect(preview.displayName, 'first_val');

        // LastName is next
        preview = UserPreview(id: '1', email: 'e', alias: null, firstName: null, lastName: 'last_val');
        expect(preview.displayName, 'last_val');

        // Email is fallback
        preview = UserPreview(id: '1', email: 'email_val', alias: null, firstName: null, lastName: null);
        expect(preview.displayName, 'email_val');
      });
    });
  });
}
