class AppConfig {
  static const domain = String.fromEnvironment('AUTH0_DOMAIN');
  static const clientId = String.fromEnvironment('AUTH0_CLIENTID');
  static const redirectUrl = String.fromEnvironment('AUTH0_REDIRECT_URL', defaultValue: 'http://localhost:3000');
}