import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/model/blog_post.dart';

class BlogRepository {
  final _controller = StreamController<BlogEvent>();

  List<BlogPost> blogs = [
      BlogPost(
          id: "1",
          title: "Strange Logs in My System",
          author: "cedric_dev",
          date: "Mar 2, 2006",
          excerpt: "I’ve been seeing patterns in my logs that I can’t explain...",
          comments: 12,
          article: '''
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

<urlembed>https://example.com</urlembed>

---
'''
        ),
        BlogPost(
          id: "2",
          title: "Exploring a Forgotten Game",
          author: "cedric_dev",
          date: "Feb 24, 2006",
          excerpt: "I found something interesting while browsing old archives...",
          comments: 8,
          article: '''
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
''',
        ),
  ];

  BlogRepository();

  Stream<BlogEvent> get data async* {
    yield* _controller.stream;
  }

  Future<List<BlogPost>> getBlogPosts(bool fromCache) async {
    if (!fromCache) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return List.of(blogs);
  }

  Future<BlogPost> getBlogPost(String blogId) async {
    return blogs[int.tryParse(blogId)!];
  }

  void dispose() => _controller.close();
}
