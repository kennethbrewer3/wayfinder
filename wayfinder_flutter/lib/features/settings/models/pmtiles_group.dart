class PmtilesGroup {
  const PmtilesGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.showOnMap,
  });

  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final bool showOnMap;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'showOnMap': showOnMap,
      };

  factory PmtilesGroup.fromJson(Map<String, dynamic> json) {
    return PmtilesGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      showOnMap: json['showOnMap'] as bool? ?? false,
    );
  }
}
