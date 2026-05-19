const String kAnthropicApiKey =
    String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
const String kAnthropicEndpoint = 'https://api.anthropic.com/v1/messages';
const String kAnthropicVersion = '2023-06-01';
const String kAnthropicModel = 'claude-haiku-4-5-20251001';
const int kAnthropicMaxTokens = 300;
