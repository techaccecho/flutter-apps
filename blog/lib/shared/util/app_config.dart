class AppConfig {
  static const domain = String.fromEnvironment('AUTH0_DOMAIN');
  static const clientId = String.fromEnvironment('AUTH0_CLIENTID');
  static const audience = String.fromEnvironment('AUTH0_AUDIENCE');
  static const redirectUrl =
      String.fromEnvironment('AUTH0_REDIRECT_URL', defaultValue: 'http://localhost:3000');
  static const blogApiBaseUrl = String.fromEnvironment(
    'BLOG_API_BASE_URL',
    defaultValue: 'http://localhost:3000/blog-api',
  );
  static const stateApiBaseUrl = String.fromEnvironment(
    'STATE_API_BASE_URL',
    defaultValue: 'http://localhost:3004/state-api',
  );
  static const puzzleAppBaseUrl = String.fromEnvironment(
    'PUZZLE_APP_BASE_URL',
    defaultValue: 'http://localhost:3005',
  );
  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'echo_api_dev_7f8a9c2b4d1e3f5a6b7c8d9e0f1a2b3c',
  );
}