import 'package:codex_dev/app/app_theme.dart';
import 'package:codex_dev/features/chat/chat_models.dart';
import 'package:codex_dev/features/chat/widgets/chat_message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long chat history starts at the newest message', (tester) async {
    await _pumpMessageList(tester);
    await tester.pumpAndSettle();

    final listRect = tester.getRect(find.byKey(const Key('chat-message-list')));
    final lastRect = tester.getRect(find.text('message 29'));
    expect(lastRect.bottom, lessThanOrEqualTo(listRect.bottom));
    expect(lastRect.top, greaterThanOrEqualTo(listRect.top));
    expect(find.byKey(const Key('chat-scroll-to-bottom-button')), findsNothing);
  });

  testWidgets(
    'jump to latest button appears away from bottom and scrolls down',
    (tester) async {
      await _pumpMessageList(tester);
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('chat-message-list')),
        const Offset(0, 420),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('chat-scroll-to-bottom-button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('chat-scroll-to-bottom-button')));
      await tester.pumpAndSettle();

      final listRect = tester.getRect(
        find.byKey(const Key('chat-message-list')),
      );
      final lastRect = tester.getRect(find.text('message 29'));
      expect(lastRect.bottom, lessThanOrEqualTo(listRect.bottom));
      expect(lastRect.top, greaterThanOrEqualTo(listRect.top));
      expect(
        find.byKey(const Key('chat-scroll-to-bottom-button')),
        findsNothing,
      );
    },
  );

  testWidgets('streaming message renders its own progress text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              ChatMessageModel(
                id: 'assistant-stream',
                threadId: AgentThread.c1.threadId,
                role: ChatMessageRole.assistant,
                content: '',
                status: ChatMessageStatus.streaming,
                createdAt: DateTime(2026),
                streamingProgress: 'Running command: /bin/bash -lc ls',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Codex thinking'), findsOneWidget);
    expect(find.text('Running command: /bin/bash -lc ls'), findsOneWidget);
  });

  testWidgets('scrolls as the latest assistant answer grows', (tester) async {
    final initialMessages = _messagesWithAssistantTail('Short answer.');
    await _pumpMessageListWith(tester, initialMessages);
    await tester.pumpAndSettle();

    const expandedAnswer = '''Short answer.

More detail arrived after the first response chunk.
The bubble is taller now, and the newest answer should remain visible without a manual scroll.
''';
    await _pumpMessageListWith(
      tester,
      _replaceTailContent(initialMessages, expandedAnswer),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();

    _expectTextVisibleInMessageList(tester, expandedAnswer);
    expect(find.byKey(const Key('chat-scroll-to-bottom-button')), findsNothing);
  });

  testWidgets('scrolls as the latest assistant thinking text changes', (
    tester,
  ) async {
    final initialMessages = _messagesWithAssistantTail(
      '',
      status: ChatMessageStatus.streaming,
      streamingProgress: 'Starting Codex turn...',
    );
    await _pumpMessageListWith(tester, initialMessages);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    const updatedProgress = '''Running command: /bin/bash -lc flutter test
Collecting output from the test runner before the assistant answer is ready.''';
    await _pumpMessageListWith(
      tester,
      _replaceTailContent(
        initialMessages,
        '',
        status: ChatMessageStatus.streaming,
        streamingProgress: updatedProgress,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();

    _expectTextVisibleInMessageList(tester, updatedProgress);
    expect(find.byKey(const Key('chat-scroll-to-bottom-button')), findsNothing);
  });
}

Future<void> _pumpMessageList(WidgetTester tester) async {
  await _pumpMessageListWith(tester, _messages());
}

Future<void> _pumpMessageListWith(
  WidgetTester tester,
  List<ChatMessageModel> messages,
) async {
  tester.view.physicalSize = const Size(390, 620);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SizedBox(height: 360, child: ChatMessageList(messages: messages)),
      ),
    ),
  );
}

List<ChatMessageModel> _messages() {
  final start = DateTime(2026);
  return [
    for (var index = 0; index < 30; index++)
      ChatMessageModel(
        id: 'message-$index',
        threadId: AgentThread.c1.threadId,
        role: index.isEven ? ChatMessageRole.user : ChatMessageRole.assistant,
        content: 'message $index',
        status: ChatMessageStatus.complete,
        createdAt: start.add(Duration(seconds: index)),
      ),
  ];
}

List<ChatMessageModel> _messagesWithAssistantTail(
  String content, {
  ChatMessageStatus status = ChatMessageStatus.complete,
  String? streamingProgress,
}) {
  final messages = _messages().take(26).toList();
  messages.add(
    ChatMessageModel(
      id: 'assistant-tail',
      threadId: AgentThread.c1.threadId,
      role: ChatMessageRole.assistant,
      content: content,
      status: status,
      createdAt: DateTime(2026, 1, 1, 0, 1),
      streamingProgress: streamingProgress,
    ),
  );
  return messages;
}

List<ChatMessageModel> _replaceTailContent(
  List<ChatMessageModel> messages,
  String content, {
  ChatMessageStatus status = ChatMessageStatus.complete,
  String? streamingProgress,
}) {
  return [
    ...messages.take(messages.length - 1),
    messages.last.copyWith(
      content: content,
      status: status,
      streamingProgress: streamingProgress,
    ),
  ];
}

void _expectTextVisibleInMessageList(WidgetTester tester, String text) {
  final listRect = tester.getRect(find.byKey(const Key('chat-message-list')));
  final textRect = tester.getRect(find.text(text));
  expect(textRect.bottom, lessThanOrEqualTo(listRect.bottom));
  expect(textRect.top, greaterThanOrEqualTo(listRect.top));
}
