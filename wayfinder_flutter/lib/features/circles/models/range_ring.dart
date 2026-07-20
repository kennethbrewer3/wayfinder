import '../../tracks/models/track_transportation_mode.dart';

/// Modes supported for travel / fuel range rings.
const rangeRingModes = <TrackTransportationMode>[
  TrackTransportationMode.onFoot,
  TrackTransportationMode.horse,
  TrackTransportationMode.bike,
  TrackTransportationMode.motorcycle,
  TrackTransportationMode.atv,
  TrackTransportationMode.landVehicle,
];

bool isRangeRingMode(TrackTransportationMode mode) =>
    rangeRingModes.contains(mode);

bool rangeRingModeUsesFuel(TrackTransportationMode mode) {
  return switch (mode) {
    TrackTransportationMode.motorcycle ||
    TrackTransportationMode.atv ||
    TrackTransportationMode.landVehicle => true,
    _ => false,
  };
}

enum RangeRingAnchor {
  marker,
  home,
  point;

  String toJson() => name;

  static RangeRingAnchor? fromJson(Object? raw) {
    return switch (raw) {
      'marker' => RangeRingAnchor.marker,
      'home' => RangeRingAnchor.home,
      'point' => RangeRingAnchor.point,
      _ => null,
    };
  }
}

enum RangeRingBasis {
  duration,
  fuel;

  String toJson() => name;

  static RangeRingBasis fromJson(Object? raw) {
    return switch (raw) {
      'fuel' => RangeRingBasis.fuel,
      _ => RangeRingBasis.duration,
    };
  }
}

/// Planning assumptions used to compute a range ring radius.
class RangeRingAssumptions {
  const RangeRingAssumptions({
    required this.speedKmh,
    this.economyLPer100km,
    this.tankLiters,
  });

  final double speedKmh;
  final double? economyLPer100km;
  final double? tankLiters;

  Map<String, dynamic> toJson() => {
    'speedKmh': speedKmh,
    if (economyLPer100km != null) 'economyLPer100km': economyLPer100km,
    if (tankLiters != null) 'tankLiters': tankLiters,
  };

  static RangeRingAssumptions? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final speed = raw['speedKmh'];
    if (speed is! num || speed <= 0) {
      return null;
    }
    final economy = raw['economyLPer100km'];
    final tank = raw['tankLiters'];
    return RangeRingAssumptions(
      speedKmh: speed.toDouble(),
      economyLPer100km: economy is num && economy > 0
          ? economy.toDouble()
          : null,
      tankLiters: tank is num && tank > 0 ? tank.toDouble() : null,
    );
  }
}

/// Metadata stored on a circle that was created as a mode-based range ring.
class RangeRingSpec {
  const RangeRingSpec({
    required this.mode,
    required this.basis,
    required this.assumptions,
    this.anchor,
    this.markerId,
    this.durationHours,
    this.fuelLiters,
  });

  final TrackTransportationMode mode;
  final RangeRingBasis basis;
  final RangeRingAssumptions assumptions;
  final RangeRingAnchor? anchor;
  final String? markerId;
  final double? durationHours;
  final double? fuelLiters;

  Map<String, dynamic> toJson() => {
    'mode': mode.toJson(),
    'basis': basis.toJson(),
    'assumptions': assumptions.toJson(),
    if (anchor != null) 'anchor': anchor!.toJson(),
    if (markerId != null) 'markerId': markerId,
    if (durationHours != null) 'durationHours': durationHours,
    if (fuelLiters != null) 'fuelLiters': fuelLiters,
  };

  static RangeRingSpec? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final mode = TrackTransportationMode.fromJson(raw['mode']);
    if (!isRangeRingMode(mode)) {
      return null;
    }
    final assumptions =
        RangeRingAssumptions.fromJson(raw['assumptions']) ??
        defaultRangeRingAssumptions(mode);
    final duration = raw['durationHours'];
    final fuel = raw['fuelLiters'];
    return RangeRingSpec(
      mode: mode,
      basis: RangeRingBasis.fromJson(raw['basis']),
      assumptions: assumptions,
      anchor: RangeRingAnchor.fromJson(raw['anchor']),
      markerId: raw['markerId']?.toString(),
      durationHours: duration is num && duration > 0
          ? duration.toDouble()
          : null,
      fuelLiters: fuel is num && fuel > 0 ? fuel.toDouble() : null,
    );
  }
}

/// Default planning speeds / fuel figures for range rings.
///
/// These are rough cross-country estimates, not vehicle specs. ATV defaults
/// use a smaller tank and thirstier economy than a typical road vehicle.
RangeRingAssumptions defaultRangeRingAssumptions(
  TrackTransportationMode mode,
) {
  return switch (mode) {
    TrackTransportationMode.onFoot => const RangeRingAssumptions(speedKmh: 5),
    TrackTransportationMode.horse => const RangeRingAssumptions(speedKmh: 8),
    TrackTransportationMode.bike => const RangeRingAssumptions(speedKmh: 16),
    TrackTransportationMode.motorcycle => const RangeRingAssumptions(
      speedKmh: 90,
      economyLPer100km: 4.5,
      tankLiters: 15,
    ),
    TrackTransportationMode.atv => const RangeRingAssumptions(
      speedKmh: 45,
      economyLPer100km: 12,
      tankLiters: 12,
    ),
    TrackTransportationMode.landVehicle => const RangeRingAssumptions(
      speedKmh: 90,
      economyLPer100km: 9,
      tankLiters: 60,
    ),
    _ => const RangeRingAssumptions(speedKmh: 5),
  };
}

double? rangeRingRadiusMeters({
  required TrackTransportationMode mode,
  required RangeRingBasis basis,
  required RangeRingAssumptions assumptions,
  double? durationHours,
  double? fuelLiters,
}) {
  return switch (basis) {
    RangeRingBasis.duration => () {
      final hours = durationHours;
      if (hours == null || hours <= 0 || assumptions.speedKmh <= 0) {
        return null;
      }
      return assumptions.speedKmh * hours * 1000;
    }(),
    RangeRingBasis.fuel => () {
      if (!rangeRingModeUsesFuel(mode)) {
        return null;
      }
      final fuel = fuelLiters;
      final economy = assumptions.economyLPer100km;
      if (fuel == null || fuel <= 0 || economy == null || economy <= 0) {
        return null;
      }
      // liters / (L/100km) → hundreds of km → meters
      return (fuel / economy) * 100000;
    }(),
  };
}
