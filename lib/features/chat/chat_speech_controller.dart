import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ChatSpeechEngine {
  void setStartHandler(VoidCallback handler);
  void setCompletionHandler(VoidCallback handler);
  void setCancelHandler(VoidCallback handler);
  void setErrorHandler(ValueChanged<Object?> handler);
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> dispose();
}

// Speech is intentionally unavailable; no platform or network plugin is loaded.
class DisabledSpeechEngine implements ChatSpeechEngine {
  @override
  void setStartHandler(VoidCallback handler) {}
  @override
  void setCompletionHandler(VoidCallback handler) {}
  @override
  void setCancelHandler(VoidCallback handler) {}
  @override
  void setErrorHandler(ValueChanged<Object?> handler) {}
  @override
  Future<void> speak(String text) async {
    throw UnsupportedError('Demo has no speech engine');
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class ChatSpeechController extends ChangeNotifier {
  ChatSpeechController({ChatSpeechEngine? engine})
    : _engine = engine ?? DisabledSpeechEngine() {
    _engine.setStartHandler(_handleStart);
    _engine.setCompletionHandler(_clearActiveSpeech);
    _engine.setCancelHandler(_clearActiveSpeech);
    _engine.setErrorHandler((_) => _handleError());
  }

  final ChatSpeechEngine _engine;
  String? _activeMessageId;

  String? get activeMessageId => _activeMessageId;
  bool get isSpeaking => _activeMessageId != null;

  Future<String?> speakMessage({
    required String messageId,
    required String text,
  }) async {
    final speechText = markdownToSpeechText(text);
    if (speechText.isBlank) return 'Nothing to speak';

    _activeMessageId = messageId;
    notifyListeners();
    try {
      await _engine.speak(speechText);
      return null;
    } catch (_) {
      _clearActiveSpeech();
      return 'Text to speech unavailable';
    }
  }

  Future<void> stop() async {
    _clearActiveSpeech();
    try {
      await _engine.stop();
    } catch (_) {
      // The visual state is already cleared; platform errors are not actionable.
    }
  }

  void _handleStart() {
    if (_activeMessageId != null) notifyListeners();
  }

  void _handleError() {
    _clearActiveSpeech();
  }

  void _clearActiveSpeech() {
    if (_activeMessageId == null) return;
    _activeMessageId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_engine.dispose());
    super.dispose();
  }
}

String markdownToSpeechText(String markdown) {
  var text = markdown.replaceAll('\u0000', ' ');
  text = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  text = text.replaceAllMapped(RegExp(r'`([^`]*)`'), (match) {
    return match.group(1) ?? '';
  });
  text = text.replaceAllMapped(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), (match) {
    return match.group(1) ?? '';
  });
  text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (match) {
    return match.group(1) ?? '';
  });
  text = text.replaceAll(RegExp(r'^[ \t]*#{1,6}[ \t]*', multiLine: true), '');
  text = text.replaceAll(RegExp(r'^[ \t]*[-*+][ \t]+', multiLine: true), '');
  text = text.replaceAll(RegExp(r'^[ \t]*>[ \t]?', multiLine: true), '');
  text = text.replaceAll(RegExp(r'[*_~>#|]'), ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

extension on String {
  bool get isBlank => trim().isEmpty;
}
