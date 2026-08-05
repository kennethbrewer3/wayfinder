import '../../routing/models/routing_models.dart';

/// OSM A→B route snapshot stored inside an offline pack for no-network follow.
///
/// Computed while the routing server is reachable during pack prepare. Field
/// clients load these without calling GraphHopper again.
class OfflinePackedRoute {
  const OfflinePackedRoute({
    required this.id,
    required this.destinationLabel,
    required this.profile,
    required this.origin,
    required this.result,
    required this.preparedAt,
    this.destinationMarkerId,
  });

  final String id;
  final String destinationLabel;
  final String? destinationMarkerId;
  final RoutingProfile profile;
  final RoutingPoint origin;
  final RoutingResult result;
  final DateTime preparedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'destinationLabel': destinationLabel,
    'destinationMarkerId': destinationMarkerId,
    'profile': profile.apiValue,
    'origin': origin.toJson(),
    'result': result.toJson(),
    'preparedAt': preparedAt.toIso8601String(),
  };

  factory OfflinePackedRoute.fromJson(Map<String, dynamic> json) {
    final profileWire = json['profile'] as String? ?? 'foot';
    final profile = RoutingProfile.values.firstWhere(
      (value) => value.apiValue == profileWire,
      orElse: () => RoutingProfile.foot,
    );
    return OfflinePackedRoute(
      id: json['id'] as String? ?? '',
      destinationLabel: json['destinationLabel'] as String? ?? 'Route',
      destinationMarkerId: json['destinationMarkerId'] as String?,
      profile: profile,
      origin: RoutingPoint.fromJson(
        json['origin'] as Map<String, dynamic>? ?? const {'lat': 0, 'lon': 0},
      ),
      result: RoutingResult.fromJson(
        json['result'] as Map<String, dynamic>? ?? const {},
      ),
      preparedAt: DateTime.parse(
        json['preparedAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}
