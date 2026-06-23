class AppConfig {
  static const domain = String.fromEnvironment('AUTH0_DOMAIN');
  static const clientId = String.fromEnvironment('AUTH0_CLIENTID');
  static const audience = String.fromEnvironment('AUTH0_AUDIENCE');
  static const redirectUrl = String.fromEnvironment('AUTH0_REDIRECT_URL', defaultValue: 'http://localhost:3000');
  static const blogApiBaseUrl = String.fromEnvironment('BLOG_API_BASE_URL', defaultValue: 'http://localhost:3000/blog-api');
}