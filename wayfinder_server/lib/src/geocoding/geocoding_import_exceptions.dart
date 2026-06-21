/// Thrown when a geocoding import is cancelled by the user.
final class ImportCancelledException implements Exception {
  const ImportCancelledException();

  @override
  String toString() => 'Import cancelled.';
}
