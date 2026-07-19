import '../../elevation/utils/path_profile.dart';
import '../models/line_geometry.dart';

/// Merge line geometries in [parts] order into one polyline.
///
/// Keeps every control point. Each part after the first may be reversed so its
/// nearer endpoint connects to the current tip. Shared join vertices (~1 m)
/// are not duplicated.
LineGeometry mergeLineGeometries(List<LineGeometry> parts) {
  final usable = [
    for (final part in parts)
      if (part.isValid) part,
  ];
  if (usable.isEmpty) {
    throw ArgumentError('Need at least one valid line to merge');
  }
  if (usable.length == 1) {
    return usable.first;
  }

  final legs = [
    for (var i = 0; i < usable.length; i++)
      PathProfileLeg(
        id: '$i',
        name: '$i',
        points: usable[i].points,
      ),
  ];
  final points = combinePathLegs(legs);
  final first = usable.first;
  final anySmooth = usable.any((g) => g.pathMode == LinePathMode.smooth);
  final notes = _mergeNotes(usable);

  return first.copyWith(
    points: points,
    pathMode: anySmooth ? LinePathMode.smooth : first.pathMode,
    notes: notes,
    clearNotes: notes == null,
  );
}

String? _mergeNotes(List<LineGeometry> parts) {
  final chunks = <String>[];
  for (final part in parts) {
    final note = part.notes?.trim();
    if (note != null && note.isNotEmpty && !chunks.contains(note)) {
      chunks.add(note);
    }
  }
  if (chunks.isEmpty) {
    return null;
  }
  return chunks.join('\n\n');
}
