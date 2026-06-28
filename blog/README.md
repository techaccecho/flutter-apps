# Blog.NET

This is the blog site used by Cedric to document his research and testing of Echo.

## What can it do?

- View, write and share blog posts.
- Open a blog post to read the full post content and its comments.
- Create and interact with forum topics.
- View user profiles from author/comment links.
- Allow administrators to access the archived user directory.

## Layout Behavior

The web layout is responsive:

- Mobile widths use a compact header layout.
- Tablet widths show a fixed-width sidebar with flexible content.
- Desktop widths use the full browser width with a `2:8` sidebar/content split, including maximized wide monitors.

## Prerequisites

Before you get started, ensure you have the following installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- An editor of your choice:

- VS Code with the Flutter and Dart extensions

## Getting Started

### 1. Clone and Navigate

Navigate to the blog application directory:

```bash
cd flutter-apps/blog
```

### 2. Install Dependencies

Fetch the required Flutter packages:

```bash
flutter pub get
```

### 3. Local Environment and Configuration

The project relies on external configuration, such as Auth0 settings and API base URLs.

You can run the application either:

- Using a run script, or

- Directly from your terminal, or

- Using a pre-configured VS Code launch task.

## 4. Running the App locally

### Option A: Run using the run script

```bash
sh run_dev.sh
```

### Option B: Run via the Terminal

Run the application in Chrome on port `8080`:

```bash
flutter run -d chrome --web-port 8080 \
  --dart-define=AUTH0_DOMAIN=<replace_auth0_domain> \
  --dart-define=AUTH0_CLIENTID=<replace_with_auth0_client_id> \
  --dart-define=AUTH0_AUDIENCE=<replace_with_auth0_audience> \
  --dart-define=AUTH0_REDIRECT_URL=<replace_with_auth0_redirect_url> \
  --dart-define=BLOG_API_BASE_URL=<replace_blog_api_base_url>
```

### Option C: Run via VS Code

For easier debugging, create a `.vscode/launch.json` file in your workspace and add:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Dev Engine)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--web-port",
        "8080"
      ],
      "toolArgs": [
        "--dart-define",
        "AUTH0_DOMAIN=<replace_with_auth0_domain>",
        "--dart-define",
        "AUTH0_CLIENTID=<replace_with_auth0_client_id>",
        "--dart-define",
        "AUTH0_AUDIENCE=<replace_with_auth0_audience>",
        "--dart-define",
        "AUTH0_REDIRECT_URL=<replace_with_auth0_redirect_url>",
        "--dart-define",
        "BLOG_API_BASE_URL=<replace_with_blog_api_base_url>"
      ]
    }
  ]
}
```

Then:

1. Open the project in VS Code.
2. Press `F5`, or open the **Run and Debug** tab.
3. Select **Flutter (Dev Engine)** from the configuration dropdown.
4. Click **Start Debugging**.

## 💡 Backend Requirement

The frontend expects the Backend Blog Service to be running locally at:

```text
http://localhost:3000/blog-api
```

Ensure the backend repository is running before using the application.
