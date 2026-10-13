enum ActivityLevel { info, success, warning, error }

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.level,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String detail;
  final ActivityLevel level;
  final DateTime createdAt;
}
