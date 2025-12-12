class Report {
  final String id;
  final List<String> ideas;
  final List<String> feelings;
  final List<String> reminders;
  final List<String> actionItems;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.ideas,
    required this.feelings,
    required this.reminders,
    required this.actionItems,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] as Map<String, dynamic>;
    return Report(
      id: json['id'] as String,
      ideas: List<String>.from(reportData['ideas'] ?? []),
      feelings: List<String>.from(reportData['feelings'] ?? []),
      reminders: List<String>.from(reportData['reminders'] ?? []),
      actionItems: List<String>.from(reportData['action_items'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ideas': ideas,
      'feelings': feelings,
      'reminders': reminders,
      'action_items': actionItems,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
