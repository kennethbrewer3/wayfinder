import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('enqueue persists and dedupes by eventId', () async {
    final store = RadioOutboxStore();
    final event = RadioDomainEvent.markerDelete(
      eventId: '11111111-1111-1111-1111-111111111111',
      entityId: '22222222-2222-2222-2222-222222222222',
      revisedAtSeconds: 100,
    );
    await store.enqueue(event);
    await store.enqueue(event);
    final loaded = await store.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.decode(), event);
  });
}
