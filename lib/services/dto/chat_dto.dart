class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
  });

  final String id;
  final String threadId;
  final String role;
  final String content;
}
