class ConversationTurn {
  const ConversationTurn({
    required this.role,
    required this.content,
  });

  /// `"user"` or `"model"` (API contract).
  final String role;
  final String content;
}

