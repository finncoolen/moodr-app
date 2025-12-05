class Report {
  final String emotional;
  final String cognitive;
  final String physical;
  final String motivational;
  final String social;
  final DateTime createdAt;

  Report({
    required this.emotional,
    required this.cognitive,
    required this.physical,
    required this.motivational,
    required this.social,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] as Map<String, dynamic>;
    return Report(
      emotional: reportData['emotional'] as String,
      cognitive: reportData['cognitive'] as String,
      physical: reportData['physical'] as String,
      motivational: reportData['motivational'] as String,
      social: reportData['social'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotional': emotional,
      'cognitive': cognitive,
      'physical': physical,
      'motivational': motivational,
      'social': social,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
