import 'package:flutter/foundation.dart';

import '../../services/codex_api_client.dart';
import 'chat_models.dart';

class ChatController extends ChangeNotifier {
  ChatController({required this.apiClient, this.recordActivity}) {
    _threads = {
      for (final thread in AgentThread.values)
        thread: ChatThreadModel(thread: thread, messages: const []),
    };
  }

  final CodexApiClient apiClient;
  final void Function(String title, String detail)? recordActivity;
  late Map<AgentThread, ChatThreadModel> _threads;
  final Set<AgentThread> _cancelledThreads = <AgentThread>{};
  List<ProjectSummary> projects = const [];
  List<CodexModelPreset> modelPresets = CodexModelPreset.fallbackPresets;
  AgentThread selectedThread = AgentThread.c1;
  bool loaded = false;

  List<AgentThread> get tabs => AgentThread.values;
  ChatThreadModel get active => _threads[selectedThread]!;
  Map<AgentThread, ChatThreadModel> get threads => Map.unmodifiable(_threads);

  Future<void> load() async {
    try {
      projects = await apiClient.listProjects();
      recordActivity?.call(
        'Project list loaded',
        projects.isEmpty
            ? 'No registered projects were reported by the server.'
            : '${projects.length} projects available.',
      );
    } catch (error) {
      projects = const [];
      recordActivity?.call('Project endpoint unavailable', '$error');
    }
    try {
      modelPresets = await apiClient.listModelPresets();
      recordActivity?.call(
        'Model presets loaded',
        '${modelPresets.length} presets available.',
      );
    } catch (error) {
      modelPresets = CodexModelPreset.fallbackPresets;
      recordActivity?.call(
        'Model presets fallback',
        'Using local fallback presets.',
      );
    }
    for (final thread in AgentThread.values) {
      final loadedThread = await apiClient.getThread(thread.threadId);
      final project = _projectForThread(loadedThread);
      final preset = _presetForThread(loadedThread);
      _threads[thread] = loadedThread.copyWith(
        workingDirectory: loadedThread.workingDirectory.isNotEmpty
            ? loadedThread.workingDirectory
            : project?.rootPath,
        selectedProjectId: project?.id,
        selectedModelId: preset.id,
        modelLabel: preset.label,
      );
      if (loadedThread.recoveredActiveTurn) {
        recordActivity?.call(
          'Recovery state detected',
          '${thread.label} has a server turn still running.',
        );
      }
    }
    loaded = true;
    notifyListeners();
  }

  void selectThread(AgentThread thread) {
    selectedThread = thread;
    _threads[thread] = _threads[thread]!.copyWith(hasUnread: false);
    notifyListeners();
  }

  void updateDraft(String value) {
    _threads[selectedThread] = active.copyWith(draft: value);
    notifyListeners();
  }

  void updateWorkingDirectory(String value) {
    _threads[selectedThread] = active.copyWith(
      workingDirectory: value,
      clearSelectedProjectId: true,
    );
    notifyListeners();
  }

  Future<void> addProject({
    required String name,
    required String rootPath,
  }) async {
    final cleanRoot = rootPath.trim();
    if (cleanRoot.isEmpty) {
      _threads[selectedThread] = active.copyWith(
        errorMessage: 'Repository path is required.',
      );
      notifyListeners();
      return;
    }
    try {
      projects = await apiClient.addProject(name: name, rootPath: cleanRoot);
      final selected = projects.firstWhere(
        (project) => project.rootPath == cleanRoot,
        orElse: () => ProjectSummary(
          id: cleanRoot,
          displayName: name.trim().isEmpty
              ? cleanRoot.split('/').where((part) => part.isNotEmpty).last
              : name.trim(),
          rootPath: cleanRoot,
        ),
      );
      _threads[selectedThread] = active.copyWith(
        workingDirectory: selected.rootPath,
        selectedProjectId: selected.id,
        errorMessage: null,
      );
      recordActivity?.call('Repository added', selected.displayName);
    } catch (error) {
      _threads[selectedThread] = active.copyWith(
        errorMessage: 'Could not add repository: $error',
      );
      recordActivity?.call('Repository add failed', '$error');
    }
    notifyListeners();
  }

  void selectProject(ProjectSummary project) {
    _threads[selectedThread] = active.copyWith(
      workingDirectory: project.rootPath,
      selectedProjectId: project.id,
      errorMessage: null,
    );
    recordActivity?.call('Project selected', project.displayName);
    notifyListeners();
  }

  void updateModel(String presetId) {
    final preset = modelPresets.firstWhere(
      (item) => item.id == presetId,
      orElse: () => modelPresets.first,
    );
    _threads[selectedThread] = active.copyWith(
      selectedModelId: preset.id,
      modelLabel: preset.label,
      errorMessage: null,
    );
    recordActivity?.call('Model selected', preset.label);
    notifyListeners();
  }

  Future<void> sendActiveDraft() async {
    final prompt = active.draft.trim();
    if (prompt.isEmpty) return;
    if (active.isSending) {
      _queuePrompt(prompt);
      return;
    }
    await _sendPrompt(selectedThread, prompt);
  }

  void clearActiveQueue() {
    final count = active.queuedPrompts.length;
    _threads[selectedThread] = active.copyWith(
      queuedPrompts: const [],
      queueWarning: null,
    );
    recordActivity?.call('Queued prompts cleared', '$count prompts removed.');
    notifyListeners();
  }

  void removeQueuedPrompt(int index) {
    final queue = [...active.queuedPrompts];
    if (index < 0 || index >= queue.length) return;
    final removed = queue.removeAt(index);
    _threads[selectedThread] = active.copyWith(queuedPrompts: queue);
    recordActivity?.call('Queued prompt removed', _summarize(removed));
    notifyListeners();
  }

  Future<void> _sendPrompt(AgentThread thread, String prompt) async {
    final state = _threads[thread]!;
    final now = DateTime.now();
    final user = ChatMessageModel(
      id: 'user-${now.microsecondsSinceEpoch}',
      threadId: state.thread.threadId,
      role: ChatMessageRole.user,
      content: prompt,
      status: ChatMessageStatus.complete,
      createdAt: now,
    );
    final placeholder = ChatMessageModel(
      id: 'assistant-${now.microsecondsSinceEpoch}',
      threadId: state.thread.threadId,
      role: ChatMessageRole.assistant,
      content: 'Thinking...',
      status: ChatMessageStatus.streaming,
      createdAt: now,
    );
    _threads[thread] = state.copyWith(
      draft: '',
      isSending: true,
      recoveredActiveTurn: false,
      streamingProgress: 'Starting simulated turn...',
      errorMessage: null,
      queueWarning: null,
      messages: [...state.messages, user, placeholder],
    );
    recordActivity?.call(
      'Stream started',
      '${state.thread.label}: ${_summarize(prompt)}',
    );
    notifyListeners();

    try {
      final currentState = _threads[thread]!;
      final preset = modelPresets.firstWhere(
        (item) => item.id == currentState.selectedModelId,
        orElse: () => modelPresets.first,
      );
      _cancelledThreads.remove(thread);
      var cancelledLocally = false;
      await for (final response in apiClient.streamTurn(
        state.thread.threadId,
        prompt,
        workingDirectory: currentState.workingDirectory,
        modelPreset: preset,
      )) {
        if (_cancelledThreads.contains(thread)) {
          recordActivity?.call('Stream cancelled', state.thread.label);
          cancelledLocally = true;
          break;
        }
        final current = _threads[thread]!;
        final messages = current.messages
            .map(
              (message) =>
                  message.id == placeholder.id ||
                      (message.role == ChatMessageRole.assistant &&
                          message.status == ChatMessageStatus.streaming)
                  ? response
                  : message,
            )
            .toList(growable: false);
        _threads[thread] = current.copyWith(
          messages: messages,
          isSending: response.status == ChatMessageStatus.streaming,
          streamingProgress: response.status == ChatMessageStatus.streaming
              ? response.streamingProgress ??
                    current.streamingProgress ??
                    'Codex turn running'
              : null,
          hasUnread: response.status == ChatMessageStatus.streaming
              ? current.hasUnread
              : selectedThread != thread,
          errorMessage: response.status == ChatMessageStatus.failed
              ? response.content
              : null,
        );
        notifyListeners();
      }
      if (cancelledLocally) {
        _cancelledThreads.remove(thread);
        notifyListeners();
        return;
      }
      final current = _threads[thread]!;
      _threads[thread] = current.copyWith(
        isSending: false,
        recoveredActiveTurn: false,
        streamingProgress: null,
        hasUnread: selectedThread != thread,
      );
      recordActivity?.call('Stream completed', state.thread.label);
    } catch (error) {
      final current = _threads[thread]!;
      _threads[thread] = current.copyWith(
        isSending: false,
        recoveredActiveTurn: false,
        streamingProgress: null,
        errorMessage: 'Codex unavailable: $error',
      );
      recordActivity?.call('Stream failed', '$error');
    }
    notifyListeners();
    if (!_cancelledThreads.remove(thread)) {
      await _drainQueue(thread);
    }
  }

  Future<void> cancelActiveTurn() async {
    final thread = selectedThread;
    final state = _threads[thread]!;
    if (!state.isSending) return;
    _cancelledThreads.add(thread);
    _threads[thread] = state.copyWith(
      isSending: false,
      recoveredActiveTurn: false,
      streamingProgress: null,
      errorMessage: 'Simulation stopped. Queued prompts are preserved.',
      messages: state.messages
          .map(
            (message) => message.status == ChatMessageStatus.streaming
                ? message.copyWith(status: ChatMessageStatus.cancelled)
                : message,
          )
          .toList(growable: false),
    );
    recordActivity?.call(
      'Stream cancelled',
      '${thread.label}; queued prompts preserved.',
    );
    notifyListeners();
    try {
      await apiClient.cancelTurn(thread.threadId);
    } catch (error) {
      final current = _threads[thread]!;
      _threads[thread] = current.copyWith(
        errorMessage:
            'Local rendering stopped, but server cancellation could not be confirmed: $error',
      );
      notifyListeners();
    }
  }

  ProjectSummary? _projectForThread(ChatThreadModel thread) {
    if (projects.isEmpty) return null;
    if (thread.selectedProjectId != null) {
      for (final project in projects) {
        if (project.id == thread.selectedProjectId) return project;
      }
    }
    if (thread.workingDirectory.isNotEmpty) {
      for (final project in projects) {
        if (project.rootPath == thread.workingDirectory) return project;
      }
    }
    return projects.first;
  }

  CodexModelPreset _presetForThread(ChatThreadModel thread) {
    return modelPresets.firstWhere(
      (preset) => preset.id == thread.selectedModelId,
      orElse: () => modelPresets.first,
    );
  }

  void _queuePrompt(String prompt) {
    final queue = [...active.queuedPrompts];
    if (queue.contains(prompt)) {
      _threads[selectedThread] = active.copyWith(
        draft: '',
        queueWarning: 'Prompt is already queued.',
      );
      notifyListeners();
      return;
    }
    if (queue.length >= chatPromptQueueMaxDepth) {
      _threads[selectedThread] = active.copyWith(
        queueWarning: 'Queue full. Clear a prompt before adding more.',
      );
      notifyListeners();
      return;
    }
    queue.add(prompt);
    _threads[selectedThread] = active.copyWith(
      draft: '',
      queuedPrompts: queue,
      queueWarning: null,
    );
    recordActivity?.call('Queued prompt added', _summarize(prompt));
    notifyListeners();
  }

  Future<void> _drainQueue(AgentThread thread) async {
    final current = _threads[thread]!;
    if (current.isSending || current.queuedPrompts.isEmpty) return;
    final next = current.queuedPrompts.first;
    _threads[thread] = current.copyWith(
      queuedPrompts: current.queuedPrompts.skip(1).toList(growable: false),
    );
    recordActivity?.call('Queued prompt sent', _summarize(next));
    notifyListeners();
    await _sendPrompt(thread, next);
  }

  static String _summarize(String value) {
    final text = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= 80) return text;
    return '${text.substring(0, 77)}...';
  }
}
