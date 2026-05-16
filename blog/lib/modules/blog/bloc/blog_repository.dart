import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/model/author.dart';
import 'package:blog/modules/blog/model/comment.dart';
import 'package:blog/modules/blog/model/post.dart';
import 'package:blog/modules/blog/model/stats.dart';

class BlogRepository {
  final _controller = StreamController<BlogEvent>();

  List<Post> blogs = [
      Post(
          id: "1",
          title: "Strange Logs in My System",
          author: Author(id: "120213", alias: "cedric_dev"),
          createdAt: 1677628800000,
          comments: [Comment(author: Author(id: "120213", alias: "cedric_dev"), content: "I see the same thing!", createdAt: 1677628800000, id: "c1", media: [], stats: Stats(reactions: [], commentsCount: 12, viewsCount: 200))],
          content: '''
# 🚀 From Idea to Launch: Building Your First Side Project

*By DayOne Team — April 2026*

---

Starting a side project is one of the most rewarding things you can do as a developer. It’s your playground — no stakeholders, no red tape, just pure creation.

But there’s a catch: most side projects never make it past the idea stage.

Let’s fix that.

---

## 💡 Step 1: Start Smaller Than You Think

Everyone wants to build the next big thing. The mistake? Starting too big.

Instead of:
- A full social network  
- A complete e-commerce platform  

Start with:
- A single feature  
- A simple tool  
- One clear outcome  

> “Make it work, then make it better.”

<urlembed>https://puzzle-apps.vercel.app/wordsearch/puzzle?userId=120213</urlembed>

---
''', isDraft: false, isLocked: true, isPinned: false, media: [], priority: 0.0, reactions: [], stats: Stats(reactions: [], commentsCount: 12, viewsCount: 200), type: ''
        ),
        Post(
          id: "2",
          title: "Exploring a Forgotten Game",
          author: Author(id: "120213", alias: "cedric_dev"),
          createdAt: 1677628800000,
          comments: [Comment(author: Author(id: "120213", alias: "cedric_dev"), content: "I see the same thing!", createdAt: 1677628800000, id: "c1", media: [], stats: Stats(reactions: [], commentsCount: 12, viewsCount: 200))],
          content: '''
# 🚀 From Idea to Launch: Building Your First Side Project

*By DayOne Team — April 2026*

## ✍️ Step 3: Define the MVP

Your *Minimum Viable Product* should answer one question:

**What is the smallest version of this that delivers value?**

Example:

| Feature | Include in MVP? |
|--------|----------------|
| User login | ✅ Yes |
| Notifications | ❌ No |
| Dark mode | ❌ No |

Cut aggressively.

---

## ⚡ Step 4: Build Fast, Iterate Faster

Don’t aim for perfect code. Aim for **working code**.

- Ship early  
- Get feedback  
- Improve continuously  

```dart
void main() {
  print('Ship it 🚀');
}
''', isDraft: false, isLocked: true, isPinned: false, media: [], priority: 0.0, reactions: [], stats: Stats(reactions: [], commentsCount: 12, viewsCount: 200), type: ''
        ),
  ];

  BlogRepository();

  Stream<BlogEvent> get data async* {
    yield* _controller.stream;
  }

  Future<List<Post>> getBlogPosts(bool fromCache) async {
    if (!fromCache) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return List.of(blogs);
  }

  Future<Post> getBlogPost(String blogId) async {
    return blogs[int.tryParse(blogId)!];
  }

  Future<String> getCurrentAuthor() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return "cedric_dev";
  }

  void dispose() => _controller.close();
}
