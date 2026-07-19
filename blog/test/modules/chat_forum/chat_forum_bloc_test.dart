import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/chat_forum/model/create_thread.dart';
import 'package:blog/modules/chat_forum/model/update_thread.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/author.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatForumRepository extends Mock implements ChatForumRepository {}

void main() {
  late MockChatForumRepository mockRepository;
  late ChatForumBloc chatForumBloc;

  setUpAll(() {
    registerFallbackValue(CreateThread(authorId: '', title: '', content: ''));
    registerFallbackValue(UpdateThread(title: '', content: ''));
    registerFallbackValue(AddThreadComment(authorId: '', content: ''));
  });

  setUp(() {
    mockRepository = MockChatForumRepository();
    chatForumBloc = ChatForumBloc(repository: mockRepository);
  });

  tearDown(() {
    chatForumBloc.close();
  });

  group('ChatForumBloc Tests', () {
    final testThread = Thread(
      id: 'thread_123',
      author: Author(id: 'user_123', email: 'user@example.com', alias: 'user'),
      title: 'Thread Title',
      content: 'Thread Content',
      priority: 0,
      isDraft: false,
      isPinned: false,
      isLocked: false,
      participants: [],
      comments: [],
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(views: 0, comments: 0, attachments: 0, reactions: 0),
      createdAt: DateTime.now(),
    );

    group('ChatForumLoadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumLoadingState, ChatForumContentLoadedState] on success and forwards search',
        build: () {
          when(() => mockRepository.getThreads(search: 'search-term')).thenAnswer(
            (_) async => ThreadPaginatedResult(
              threads: [testThread],
              hasMore: false,
            ),
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatForumLoadEvent(search: 'search-term')),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumContentLoadedState>()
              .having((s) => s.chat.threads, 'chat.threads', [testThread])
              .having((s) => s.search, 'search', 'search-term'),
        ],
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumLoadingState, ChatForumErrorState] on failure',
        build: () {
          when(() => mockRepository.getThreads(search: any(named: 'search')))
              .thenThrow(Exception('Failed to fetch'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatForumLoadEvent(search: 'search-term')),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to load threads'),
        ],
      );
    });

    group('ChatForumRefreshEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumLoadingState, ChatForumContentLoadedState] on success, reloads without cache and omits search',
        build: () {
          when(() => mockRepository.getThreads(search: null)).thenAnswer(
            (_) async => ThreadPaginatedResult(
              threads: [testThread],
              hasMore: false,
            ),
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatForumRefreshEvent()),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumContentLoadedState>()
              .having((s) => s.chat.threads, 'chat.threads', [testThread])
              .having((s) => s.search, 'search', null),
        ],
        verify: (_) {
          verify(() => mockRepository.getThreads(search: null)).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumLoadingState, ChatForumErrorState] on failure',
        build: () {
          when(() => mockRepository.getThreads(search: any(named: 'search')))
              .thenThrow(Exception('Failed to fetch'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatForumRefreshEvent()),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to load threads'),
        ],
      );
    });

    group('ChatLoadThreadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumThreadLoadingState, ChatForumThreadLoadedState] on success',
        build: () {
          when(() => mockRepository.getThread('thread_123')).thenAnswer(
            (_) async => testThread,
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatLoadThreadEvent('thread_123')),
        expect: () => [
          isA<ChatForumThreadLoadingState>(),
          isA<ChatForumThreadLoadedState>()
              .having((s) => s.thread.id, 'thread.id', 'thread_123'),
        ],
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits [ChatForumThreadLoadingState, ChatForumThreadErrorState] on failure',
        build: () {
          when(() => mockRepository.getThread('thread_123'))
              .thenThrow(Exception('Failed to fetch thread'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatLoadThreadEvent('thread_123')),
        expect: () => [
          isA<ChatForumThreadLoadingState>(),
          isA<ChatForumThreadErrorState>(),
        ],
      );
    });

    group('ChatCreateThreadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'sanitizes/trims title/content, creates thread and reloads forum',
        build: () {
          when(() => mockRepository.createThread(any())).thenAnswer(
            (_) async => testThread,
          );
          when(() => mockRepository.getThreads(search: null)).thenAnswer(
            (_) async => ThreadPaginatedResult(
              threads: [testThread],
              hasMore: false,
            ),
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatCreateThreadEvent(
          authorId: 'user_123',
          title: '  <script>alert("hack")</script> Test Title  ',
          content: '<p>Test content onload="alert(1)"</p>',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumContentLoadedState>()
              .having((s) => s.chat.threads, 'chat.threads', [testThread]),
        ],
        verify: (_) {
          verify(() => mockRepository.createThread(any(
            that: isA<CreateThread>()
                .having((c) => c.title, 'title', 'Test Title')
                .having((c) => c.content, 'content', '<p>Test content</p>'),
          ))).called(1);
          verify(() => mockRepository.getThreads(search: null)).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'rejects empty titles and emits error state',
        build: () => chatForumBloc,
        act: (bloc) => bloc.add(const ChatCreateThreadEvent(
          authorId: 'user_123',
          title: '   ',
          content: 'Some content',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Title cannot be empty'),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createThread(any()));
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'rejects long titles (> 200 chars) and emits error state',
        build: () => chatForumBloc,
        act: (bloc) => bloc.add(ChatCreateThreadEvent(
          authorId: 'user_123',
          title: 'a' * 201,
          content: 'Some content',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Title must be 200 characters or less'),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createThread(any()));
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'rejects empty content and emits error state',
        build: () => chatForumBloc,
        act: (bloc) => bloc.add(const ChatCreateThreadEvent(
          authorId: 'user_123',
          title: 'Valid Title',
          content: '   ',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Body cannot be empty'),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.createThread(any()));
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits error state on failure to create thread',
        build: () {
          when(() => mockRepository.createThread(any()))
              .thenThrow(Exception('Fail'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatCreateThreadEvent(
          authorId: 'user_123',
          title: 'Valid Title',
          content: 'Valid content',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to create thread'),
        ],
      );
    });

    group('ChatUpdateThreadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'sanitizes/trims title/content, updates thread and emits loaded state',
        build: () {
          when(() => mockRepository.updateThread(
            id: 'thread_123',
            update: any(named: 'update'),
          )).thenAnswer((_) async => testThread);
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatUpdateThreadEvent(
          threadId: 'thread_123',
          title: '  Updated Title  ',
          content: 'Updated content',
        )),
        expect: () => [
          isA<ChatForumThreadLoadingState>(),
          isA<ChatForumThreadLoadedState>()
              .having((s) => s.thread.id, 'thread.id', 'thread_123'),
        ],
        verify: (_) {
          verify(() => mockRepository.updateThread(
            id: 'thread_123',
            update: any(
              named: 'update',
              that: isA<UpdateThread>()
                  .having((u) => u.title, 'title', 'Updated Title')
                  .having((u) => u.content, 'content', 'Updated content'),
            ),
          )).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'rejects invalid title/content and emits error state',
        build: () => chatForumBloc,
        act: (bloc) => bloc.add(const ChatUpdateThreadEvent(
          threadId: 'thread_123',
          title: '',
          content: 'Updated content',
        )),
        expect: () => [
          isA<ChatForumThreadLoadingState>(),
          const ChatForumErrorState(error: 'Title cannot be empty'),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.updateThread(
            id: any(named: 'id'),
            update: any(named: 'update'),
          ));
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits error state on repository failure',
        build: () {
          when(() => mockRepository.updateThread(
            id: any(named: 'id'),
            update: any(named: 'update'),
          )).thenThrow(Exception('Fail'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatUpdateThreadEvent(
          threadId: 'thread_123',
          title: 'Valid Title',
          content: 'Valid content',
        )),
        expect: () => [
          isA<ChatForumThreadLoadingState>(),
          const ChatForumErrorState(error: 'Unable to update thread'),
        ],
      );
    });

    group('ChatDeleteThreadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'sends delete reason, reloads forum, emits loaded state',
        build: () {
          when(() => mockRepository.deleteThread(
            'thread_123',
            reason: 'spammed',
          )).thenAnswer((_) async {});
          when(() => mockRepository.getThreads(search: null)).thenAnswer(
            (_) async => ThreadPaginatedResult(
              threads: [testThread],
              hasMore: false,
            ),
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatDeleteThreadEvent(
          threadId: 'thread_123',
          reason: 'spammed',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumContentLoadedState>()
              .having((s) => s.chat.threads, 'chat.threads', [testThread]),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteThread(
            'thread_123',
            reason: 'spammed',
          )).called(1);
          verify(() => mockRepository.getThreads(search: null)).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits error state on failure',
        build: () {
          when(() => mockRepository.deleteThread(
            any(),
            reason: any(named: 'reason'),
          )).thenThrow(Exception('Fail'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatDeleteThreadEvent(
          threadId: 'thread_123',
          reason: 'spammed',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to delete thread'),
        ],
      );
    });

    group('ChatSoftDeleteThreadEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'sends soft delete reason, reloads forum, emits loaded state',
        build: () {
          when(() => mockRepository.softDeleteThread(
            id: 'thread_123',
            reason: 'inappropriate',
          )).thenAnswer((_) async => testThread);
          when(() => mockRepository.getThreads(search: null)).thenAnswer(
            (_) async => ThreadPaginatedResult(
              threads: [testThread],
              hasMore: false,
            ),
          );
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatSoftDeleteThreadEvent(
          threadId: 'thread_123',
          reason: 'inappropriate',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumContentLoadedState>()
              .having((s) => s.chat.threads, 'chat.threads', [testThread]),
        ],
        verify: (_) {
          verify(() => mockRepository.softDeleteThread(
            id: 'thread_123',
            reason: 'inappropriate',
          )).called(1);
          verify(() => mockRepository.getThreads(search: null)).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits error state on failure',
        build: () {
          when(() => mockRepository.softDeleteThread(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          )).thenThrow(Exception('Fail'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatSoftDeleteThreadEvent(
          threadId: 'thread_123',
          reason: 'inappropriate',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to remove thread'),
        ],
      );
    });

    group('ChatAddCommentEvent', () {
      blocTest<ChatForumBloc, ChatForumState>(
        'sends thread/author ID and message, emits updated thread on success',
        build: () {
          when(() => mockRepository.addThreadComment(
            id: 'thread_123',
            request: any(named: 'request'),
          )).thenAnswer((_) async => testThread);
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatAddCommentEvent(
          threadId: 'thread_123',
          authorId: 'user_456',
          message: 'Nice comment',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          isA<ChatForumThreadLoadedState>()
              .having((s) => s.thread.id, 'thread.id', 'thread_123'),
        ],
        verify: (_) {
          verify(() => mockRepository.addThreadComment(
            id: 'thread_123',
            request: any(
              named: 'request',
              that: isA<AddThreadComment>()
                  .having((r) => r.authorId, 'authorId', 'user_456')
                  .having((r) => r.content, 'content', 'Nice comment'),
            ),
          )).called(1);
        },
      );

      blocTest<ChatForumBloc, ChatForumState>(
        'emits error state on failure',
        build: () {
          when(() => mockRepository.addThreadComment(
            id: any(named: 'id'),
            request: any(named: 'request'),
          )).thenThrow(Exception('Fail'));
          return chatForumBloc;
        },
        act: (bloc) => bloc.add(const ChatAddCommentEvent(
          threadId: 'thread_123',
          authorId: 'user_456',
          message: 'Nice comment',
        )),
        expect: () => [
          const ChatForumLoadingState(),
          const ChatForumErrorState(error: 'Unable to add comment'),
        ],
      );
    });
  });
}
