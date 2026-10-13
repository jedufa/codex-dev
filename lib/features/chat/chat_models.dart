enum AgentThread {
  c1('a', 'C1', 'codex-dev-1', 'CODEX'),
  c2('a2', 'C2', 'codex-dev-2', 'CODEX'),
  c3('a3', 'C3', 'codex-dev-3', 'CODEX'),
  c4('a4', 'C4', 'codex-dev-4', 'CODEX');

  const AgentThread(this.key, this.label, this.threadId, this.headerTitle);

  final String key;
  final String label;
  final String threadId;
  final String headerTitle;
}

enum ChatMessageRole { user, assistant }

enum ChatMessageStatus { sending, streaming, complete, failed, cancelled }

const int chatPromptQueueMaxDepth = 5;

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.displayName,
    required this.rootPath,
    this.lastUsed = false,
    this.readiness = 'unknown',
  });

  final String id;
  final String displayName;
  final String rootPath;
  final bool lastUsed;
  final String readiness;
}

class CodexModelPreset {
  const CodexModelPreset({
    required this.id,
    required this.label,
    required this.model,
    required this.reasoningEffort,
    this.description = '',
    this.isDefault = false,
    this.available = true,
    this.status = 'available',
  });

  final String id;
  final String label;
  final String model;
  final String reasoningEffort;
  final String description;
  final bool isDefault;
  final bool available;
  final String status;

  static const fallbackPresets = [
    CodexModelPreset(
      id: 'gpt-5.5-medium',
      label: 'Demo · balanced',
      model: 'gpt-5.5',
      reasoningEffort: 'medium',
      description: 'Fallback default Codex preset.',
      isDefault: true,
    ),
    CodexModelPreset(
      id: 'gpt-5.5-high',
      label: 'Demo · detailed',
      model: 'gpt-5.5',
      reasoningEffort: 'high',
      description: 'Fallback high-reasoning Codex preset.',
    ),
    CodexModelPreset(
      id: 'gpt-5.4-high',
      label: 'Demo · focused',
      model: 'gpt-5.4',
      reasoningEffort: 'high',
      description: 'Fallback high-reasoning Codex preset.',
    ),
    CodexModelPreset(
      id: 'gpt-5.4-medium',
      label: 'Demo · brief',
      model: 'gpt-5.4',
      reasoningEffort: 'medium',
      description: 'Fallback Codex preset.',
    ),
  ];

  static CodexModelPreset fromWireValue(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final preset in fallbackPresets) {
      if (preset.id.toLowerCase() == normalized) return preset;
    }
    final effort = [
      'xhigh',
      'medium',
      'high',
      'low',
    ].firstWhere((value) => normalized.endsWith('-$value'), orElse: () => '');
    if (effort.isEmpty) return fallbackPresets.first;
    final model = normalized.substring(
      0,
      normalized.length - effort.length - 1,
    );
    if (model.isEmpty) return fallbackPresets.first;
    final labelBase = model
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part.toLowerCase() == 'gpt'
              ? 'GPT'
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
    return CodexModelPreset(
      id: normalized,
      label: '$labelBase ${_reasoningEffortLabel(effort)}',
      model: model,
      reasoningEffort: effort,
      description: 'Recovered Codex model preset.',
    );
  }

  static String _reasoningEffortLabel(String effort) {
    return switch (effort) {
      'low' => 'Low',
      'medium' => 'Med',
      'high' => 'High',
      'xhigh' => 'XHigh',
      _ => effort,
    };
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
    required this.status,
    required this.createdAt,
    this.streamingProgress,
  });

  final String id;
  final String threadId;
  final ChatMessageRole role;
  final String content;
  final ChatMessageStatus status;
  final DateTime createdAt;
  final String? streamingProgress;

  ChatMessageModel copyWith({
    String? content,
    ChatMessageStatus? status,
    String? streamingProgress,
  }) {
    return ChatMessageModel(
      id: id,
      threadId: threadId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt,
      streamingProgress: streamingProgress ?? this.streamingProgress,
    );
  }
}

class ChatThreadModel {
  const ChatThreadModel({
    required this.thread,
    required this.messages,
    this.draft = '',
    this.workingDirectory = '',
    this.modelLabel = '5.5 Med',
    this.selectedModelId = 'gpt-5.5-medium',
    this.selectedProjectId,
    this.queuedPrompts = const [],
    this.isSending = false,
    this.recoveredActiveTurn = false,
    this.streamingProgress,
    this.errorMessage,
    this.queueWarning,
    this.hasUnread = false,
  });

  final AgentThread thread;
  final List<ChatMessageModel> messages;
  final String draft;
  final String workingDirectory;
  final String modelLabel;
  final String selectedModelId;
  final String? selectedProjectId;
  final List<String> queuedPrompts;
  final bool isSending;
  final bool recoveredActiveTurn;
  final String? streamingProgress;
  final String? errorMessage;
  final String? queueWarning;
  final bool hasUnread;

  ChatThreadModel copyWith({
    List<ChatMessageModel>? messages,
    String? draft,
    String? workingDirectory,
    String? modelLabel,
    String? selectedModelId,
    String? selectedProjectId,
    bool clearSelectedProjectId = false,
    List<String>? queuedPrompts,
    bool? isSending,
    bool? recoveredActiveTurn,
    String? streamingProgress,
    String? errorMessage,
    String? queueWarning,
    bool? hasUnread,
  }) {
    return ChatThreadModel(
      thread: thread,
      messages: messages ?? this.messages,
      draft: draft ?? this.draft,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      modelLabel: modelLabel ?? this.modelLabel,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      selectedProjectId: clearSelectedProjectId
          ? null
          : selectedProjectId ?? this.selectedProjectId,
      queuedPrompts: queuedPrompts ?? this.queuedPrompts,
      isSending: isSending ?? this.isSending,
      recoveredActiveTurn: recoveredActiveTurn ?? this.recoveredActiveTurn,
      streamingProgress: streamingProgress,
      errorMessage: errorMessage,
      queueWarning: queueWarning,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }
}
