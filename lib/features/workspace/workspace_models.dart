class WorkspaceStatus {
  const WorkspaceStatus({
    required this.projectName,
    required this.projectRoot,
    required this.serverUrl,
    required this.summary,
    required this.filesChanged,
  });

  final String projectName;
  final String projectRoot;
  final String serverUrl;
  final String summary;
  final int filesChanged;
}
