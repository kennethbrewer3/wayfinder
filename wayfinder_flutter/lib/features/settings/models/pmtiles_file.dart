class PmtilesFile {
  const PmtilesFile({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.addedAt,
    required this.enabledOnMap,
    this.groupIds = const [],
  });

  final String id;
  final String name;
  final int sizeBytes;
  final DateTime addedAt;
  final bool enabledOnMap;
  final List<String> groupIds;

  bool isInGroup(String groupId) => groupIds.contains(groupId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sizeBytes': sizeBytes,
        'addedAt': addedAt.toIso8601String(),
        'enabledOnMap': enabledOnMap,
        'groupIds': groupIds,
      };

  factory PmtilesFile.fromJson(Map<String, dynamic> json) {
    final rawGroupIds = json['groupIds'];
    return PmtilesFile(
      id: json['id'] as String,
      name: json['name'] as String,
      sizeBytes: json['sizeBytes'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      enabledOnMap: json['enabledOnMap'] as bool? ?? false,
      groupIds: rawGroupIds is List
          ? rawGroupIds.map((value) => value.toString()).toList()
          : const [],
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
