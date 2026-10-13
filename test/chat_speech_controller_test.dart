import 'package:codex_dev/app/app_theme.dart';
import 'package:codex_dev/features/chat/chat_models.dart';
import 'package:codex_dev/features/chat/chat_speech_controller.dart';
import 'package:codex_dev/features/chat/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSpeechEngine implements ChatSpeechEngine {
  VoidCallback? startHandler;
  VoidCallback? completionHandler;
  VoidCallback? cancelHandler;
  ValueChanged<Object?>? errorHandler;
  String? spokenText;
  int stopCount = 0;

  @override
  void setStartHandler(VoidCallback handler) {
    startHandler = handler;
  }

  @override
  void setCompletionHandler(VoidCallback handler) {
    completionHandler = handler;
  }

  @override
  void setCancelHandler(VoidCallback handler) {
    cancelHandler = handler;
  }

  @override
  void setErrorHandler(ValueChanged<Object?> handler) {
    errorHandler = handler;
  }

  @override
  Future<void> speak(String text) async {
    spokenText = text;
    startHandler?.call();
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    cancelHandler?.call();
  }

  @override
  Future<void> dispose() async {}
}

ChatMessageModel _assistantMessage() => ChatMessageModel(
  id: 'assistant-1',
  threadId: AgentThread.c1.threadId,
  role: ChatMessageRole.assistant,
  content: 'Assistant response',
  status: ChatMessageStatus.complete,
  createdAt: DateTime(2026),
);

void main() {
  test('markdownToSpeechText removes code and markdown wrappers', () {
    final text = markdownToSpeechText('''
# Heading
Read [the docs](/tmp/file.md) and `inline code`.

```dart
final secret = "skip me";
```
''');

    expect(text, 'Heading Read the docs and inline code.');
    expect(text, isNot(contains('skip me')));
  });

  test(
    'speech controller speaks cleaned assistant text and clears on stop',
    () async {
      final engine = FakeSpeechEngine();
      final controller = ChatSpeechController(engine: engine);

      final error = await controller.speakMessage(
        messageId: 'assistant-1',
        text: 'Speak `this`',
      );

      expect(error, isNull);
      expect(controller.activeMessageId, 'assistant-1');
      expect(engine.spokenText, 'Speak this');

      await controller.stop();

      expect(controller.activeMessageId, isNull);
      expect(engine.stopCount, 1);
    },
  );

  testWidgets(
    'message bubble invokes long-press action and shows speaking state',
    (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: Scaffold(
            body: ChatMessageBubble(
              message: _assistantMessage(),
              isSpeaking: true,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Speaking'), findsOneWidget);

      await tester.longPress(find.text('Assistant response'));
      await tester.pump();

      expect(longPressed, isTrue);
    },
  );
}
