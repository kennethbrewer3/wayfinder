import '../../markers/models/marker_radio.dart';

/// Radio service band for a comms-plan channel/frequency row.
enum CommsRadioService {
  ham,
  gmrs,
  frs,
  cb;

  static CommsRadioService parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'gmrs' => CommsRadioService.gmrs,
      'frs' => CommsRadioService.frs,
      'cb' || 'citizens_band' => CommsRadioService.cb,
      'ham' || 'amateur' || 'amateur_radio' => CommsRadioService.ham,
      _ => CommsRadioService.ham,
    };
  }

  String get storageValue => name;

  /// When true, frequency must come from [permittedChannelsFor].
  bool get usesPermittedChannels => this != CommsRadioService.ham;
}

/// One permitted channel/frequency for GMRS, FRS, or CB.
class PermittedRadioChannel {
  const PermittedRadioChannel({
    required this.id,
    required this.numberLabel,
    required this.frequencyMHz,
    this.defaultMode = MarkerRadioMode.fm,
    this.defaultOffsetMHz,
    this.isRepeater = false,
  });

  /// Stable id stored on the plan channel (`1`, `15R`, …).
  final String id;

  /// Display number/label (`1`, `15R`, `9`).
  final String numberLabel;
  final double frequencyMHz;
  final MarkerRadioMode defaultMode;
  final double? defaultOffsetMHz;
  final bool isRepeater;

  String listLabel() {
    final freq = frequencyMHz.toStringAsFixed(4);
    if (isRepeater) {
      return 'Ch $numberLabel · $freq MHz (+5 repeater)';
    }
    return 'Ch $numberLabel · $freq MHz';
  }
}

/// FRS channels 1–22 (FCC Part 95).
const frsPermittedChannels = <PermittedRadioChannel>[
  PermittedRadioChannel(id: '1', numberLabel: '1', frequencyMHz: 462.5625),
  PermittedRadioChannel(id: '2', numberLabel: '2', frequencyMHz: 462.5875),
  PermittedRadioChannel(id: '3', numberLabel: '3', frequencyMHz: 462.6125),
  PermittedRadioChannel(id: '4', numberLabel: '4', frequencyMHz: 462.6375),
  PermittedRadioChannel(id: '5', numberLabel: '5', frequencyMHz: 462.6625),
  PermittedRadioChannel(id: '6', numberLabel: '6', frequencyMHz: 462.6875),
  PermittedRadioChannel(id: '7', numberLabel: '7', frequencyMHz: 462.7125),
  PermittedRadioChannel(id: '8', numberLabel: '8', frequencyMHz: 467.5625),
  PermittedRadioChannel(id: '9', numberLabel: '9', frequencyMHz: 467.5875),
  PermittedRadioChannel(id: '10', numberLabel: '10', frequencyMHz: 467.6125),
  PermittedRadioChannel(id: '11', numberLabel: '11', frequencyMHz: 467.6375),
  PermittedRadioChannel(id: '12', numberLabel: '12', frequencyMHz: 467.6625),
  PermittedRadioChannel(id: '13', numberLabel: '13', frequencyMHz: 467.6875),
  PermittedRadioChannel(id: '14', numberLabel: '14', frequencyMHz: 467.7125),
  PermittedRadioChannel(id: '15', numberLabel: '15', frequencyMHz: 462.5500),
  PermittedRadioChannel(id: '16', numberLabel: '16', frequencyMHz: 462.5750),
  PermittedRadioChannel(id: '17', numberLabel: '17', frequencyMHz: 462.6000),
  PermittedRadioChannel(id: '18', numberLabel: '18', frequencyMHz: 462.6250),
  PermittedRadioChannel(id: '19', numberLabel: '19', frequencyMHz: 462.6500),
  PermittedRadioChannel(id: '20', numberLabel: '20', frequencyMHz: 462.6750),
  PermittedRadioChannel(id: '21', numberLabel: '21', frequencyMHz: 462.7000),
  PermittedRadioChannel(id: '22', numberLabel: '22', frequencyMHz: 462.7250),
];

/// GMRS channels 1–22 (shared with FRS) plus repeater pairs 15R–22R.
const gmrsPermittedChannels = <PermittedRadioChannel>[
  ...frsPermittedChannels,
  PermittedRadioChannel(
    id: '15R',
    numberLabel: '15R',
    frequencyMHz: 462.5500,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '16R',
    numberLabel: '16R',
    frequencyMHz: 462.5750,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '17R',
    numberLabel: '17R',
    frequencyMHz: 462.6000,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '18R',
    numberLabel: '18R',
    frequencyMHz: 462.6250,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '19R',
    numberLabel: '19R',
    frequencyMHz: 462.6500,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '20R',
    numberLabel: '20R',
    frequencyMHz: 462.6750,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '21R',
    numberLabel: '21R',
    frequencyMHz: 462.7000,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
  PermittedRadioChannel(
    id: '22R',
    numberLabel: '22R',
    frequencyMHz: 462.7250,
    defaultOffsetMHz: 5.0,
    isRepeater: true,
  ),
];

/// CB channels 1–40 (FCC Part 95).
const cbPermittedChannels = <PermittedRadioChannel>[
  PermittedRadioChannel(
    id: '1',
    numberLabel: '1',
    frequencyMHz: 26.965,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '2',
    numberLabel: '2',
    frequencyMHz: 26.975,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '3',
    numberLabel: '3',
    frequencyMHz: 26.985,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '4',
    numberLabel: '4',
    frequencyMHz: 27.005,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '5',
    numberLabel: '5',
    frequencyMHz: 27.015,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '6',
    numberLabel: '6',
    frequencyMHz: 27.025,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '7',
    numberLabel: '7',
    frequencyMHz: 27.035,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '8',
    numberLabel: '8',
    frequencyMHz: 27.055,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '9',
    numberLabel: '9',
    frequencyMHz: 27.065,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '10',
    numberLabel: '10',
    frequencyMHz: 27.075,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '11',
    numberLabel: '11',
    frequencyMHz: 27.085,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '12',
    numberLabel: '12',
    frequencyMHz: 27.105,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '13',
    numberLabel: '13',
    frequencyMHz: 27.115,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '14',
    numberLabel: '14',
    frequencyMHz: 27.125,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '15',
    numberLabel: '15',
    frequencyMHz: 27.135,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '16',
    numberLabel: '16',
    frequencyMHz: 27.155,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '17',
    numberLabel: '17',
    frequencyMHz: 27.165,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '18',
    numberLabel: '18',
    frequencyMHz: 27.175,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '19',
    numberLabel: '19',
    frequencyMHz: 27.185,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '20',
    numberLabel: '20',
    frequencyMHz: 27.205,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '21',
    numberLabel: '21',
    frequencyMHz: 27.215,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '22',
    numberLabel: '22',
    frequencyMHz: 27.225,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '23',
    numberLabel: '23',
    frequencyMHz: 27.255,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '24',
    numberLabel: '24',
    frequencyMHz: 27.235,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '25',
    numberLabel: '25',
    frequencyMHz: 27.245,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '26',
    numberLabel: '26',
    frequencyMHz: 27.265,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '27',
    numberLabel: '27',
    frequencyMHz: 27.275,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '28',
    numberLabel: '28',
    frequencyMHz: 27.285,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '29',
    numberLabel: '29',
    frequencyMHz: 27.295,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '30',
    numberLabel: '30',
    frequencyMHz: 27.305,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '31',
    numberLabel: '31',
    frequencyMHz: 27.315,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '32',
    numberLabel: '32',
    frequencyMHz: 27.325,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '33',
    numberLabel: '33',
    frequencyMHz: 27.335,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '34',
    numberLabel: '34',
    frequencyMHz: 27.345,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '35',
    numberLabel: '35',
    frequencyMHz: 27.355,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '36',
    numberLabel: '36',
    frequencyMHz: 27.365,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '37',
    numberLabel: '37',
    frequencyMHz: 27.375,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '38',
    numberLabel: '38',
    frequencyMHz: 27.385,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '39',
    numberLabel: '39',
    frequencyMHz: 27.395,
    defaultMode: MarkerRadioMode.am,
  ),
  PermittedRadioChannel(
    id: '40',
    numberLabel: '40',
    frequencyMHz: 27.405,
    defaultMode: MarkerRadioMode.am,
  ),
];

List<PermittedRadioChannel> permittedChannelsFor(CommsRadioService service) {
  return switch (service) {
    CommsRadioService.ham => const [],
    CommsRadioService.gmrs => gmrsPermittedChannels,
    CommsRadioService.frs => frsPermittedChannels,
    CommsRadioService.cb => cbPermittedChannels,
  };
}

PermittedRadioChannel? findPermittedChannel(
  CommsRadioService service,
  String? channelId,
) {
  if (channelId == null || channelId.trim().isEmpty) {
    return null;
  }
  final id = channelId.trim();
  for (final channel in permittedChannelsFor(service)) {
    if (channel.id == id) {
      return channel;
    }
  }
  return null;
}

/// Best-effort match when loading older rows that only stored a frequency.
PermittedRadioChannel? findPermittedChannelByFrequency(
  CommsRadioService service,
  double? frequencyMHz,
) {
  if (frequencyMHz == null) {
    return null;
  }
  for (final channel in permittedChannelsFor(service)) {
    if ((channel.frequencyMHz - frequencyMHz).abs() < 0.00005 &&
        !channel.isRepeater) {
      return channel;
    }
  }
  return null;
}
