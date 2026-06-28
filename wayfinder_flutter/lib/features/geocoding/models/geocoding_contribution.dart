class GeocodingContribution {
  const GeocodingContribution({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.countryCode,
    required this.contentKey,
    required this.importedFromCrowd,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? notes;
  final String? countryCode;
  final String contentKey;
  final bool importedFromCrowd;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GeocodingContribution.fromJson(Map<String, dynamic> json) {
    return GeocodingContribution(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notes: json['notes'] as String?,
      countryCode: json['countryCode'] as String?,
      contentKey: json['contentKey'] as String? ?? '',
      importedFromCrowd: json['importedFromCrowd'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (countryCode != null && countryCode!.isNotEmpty)
        'countryCode': countryCode,
    };
  }
}

class GeocodingCrowdsourceSubmitResult {
  const GeocodingCrowdsourceSubmitResult({
    required this.submittedCount,
    required this.uploadedToGit,
    this.bundleJson,
    this.message,
  });

  final int submittedCount;
  final bool uploadedToGit;
  final String? bundleJson;
  final String? message;

  factory GeocodingCrowdsourceSubmitResult.fromJson(Map<String, dynamic> json) {
    return GeocodingCrowdsourceSubmitResult(
      submittedCount: (json['submittedCount'] as num?)?.toInt() ?? 0,
      uploadedToGit: json['uploadedToGit'] as bool? ?? false,
      bundleJson: json['bundleJson'] as String?,
      message: json['message'] as String?,
    );
  }
}
