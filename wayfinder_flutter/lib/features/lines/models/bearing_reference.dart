enum BearingReference {
  trueNorth,
  magnetic,
}

extension BearingReferenceX on BearingReference {
  String get storageValue => switch (this) {
    BearingReference.trueNorth => 'true',
    BearingReference.magnetic => 'magnetic',
  };
}

BearingReference bearingReferenceFromStorage(String? value) {
  return switch (value) {
    'magnetic' => BearingReference.magnetic,
    _ => BearingReference.trueNorth,
  };
}

String bearingReferenceToStorage(BearingReference reference) {
  return reference.storageValue;
}
