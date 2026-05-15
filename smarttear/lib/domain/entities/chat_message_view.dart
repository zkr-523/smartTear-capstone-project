class ChatMessageView {
  const ChatMessageView({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final int id;

  /// `"user"` or `"assistant"`.
  final String role;

  final String text;
  final DateTime createdAt;
}

