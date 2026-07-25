import 'package:test/test.dart';
import 'package:wayfinder_server/src/access/access_control.dart';
import 'package:wayfinder_server/src/access/wayfinder_permissions.dart';

void main() {
  group('WayfinderPermission', () {
    test('isKnown recognizes catalog entries only', () {
      expect(WayfinderPermission.isKnown(WayfinderPermission.viewMap), isTrue);
      expect(WayfinderPermission.isKnown('not_a_permission'), isFalse);
    });

    test('forEndpoint maps reads', () {
      expect(
        WayfinderPermission.forEndpoint(tag: 'mapMarker', isWrite: false),
        WayfinderPermission.viewMap,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'watchLog', isWrite: false),
        WayfinderPermission.viewWatchLog,
      );
    });

    test('forEndpoint maps writes', () {
      expect(
        WayfinderPermission.forEndpoint(tag: 'mapMarker', isWrite: true),
        WayfinderPermission.editMapObjects,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'watchLog', isWrite: true),
        WayfinderPermission.addWatchLog,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'accessControl', isWrite: true),
        WayfinderPermission.manageUsers,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'pmtiles', isWrite: true),
        WayfinderPermission.managePmtiles,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'appTheme', isWrite: true),
        WayfinderPermission.manageThemes,
      );
      expect(
        WayfinderPermission.forEndpoint(tag: 'fieldPack', isWrite: true),
        WayfinderPermission.manageBackups,
      );
    });

    test('viewer defaults are read-only map access', () {
      expect(WayfinderPermission.viewerDefaults, {WayfinderPermission.viewMap});
      expect(
        WayfinderPermission.editorDefaults.contains(
          WayfinderPermission.editMapObjects,
        ),
        isTrue,
      );
      expect(
        WayfinderPermission.editorDefaults.contains(
          WayfinderPermission.manageUsers,
        ),
        isFalse,
      );
    });
  });

  group('AccessControl permissions JSON', () {
    test('parsePermissions keeps known values only', () {
      final parsed = AccessControl.parsePermissions(
        '["view_map","edit_map_objects","made_up","manage_themes"]',
      );
      expect(
        parsed,
        {
          WayfinderPermission.viewMap,
          WayfinderPermission.editMapObjects,
          WayfinderPermission.manageThemes,
        },
      );
    });

    test('parsePermissions returns empty on invalid JSON', () {
      expect(AccessControl.parsePermissions('not-json'), isEmpty);
      expect(AccessControl.parsePermissions('{"a":1}'), isEmpty);
    });

    test('encodePermissions sorts and filters', () {
      final encoded = AccessControl.encodePermissions([
        WayfinderPermission.manageThemes,
        'nope',
        WayfinderPermission.viewMap,
        WayfinderPermission.viewMap,
      ]);
      expect(encoded, '["manage_themes","view_map"]');
      expect(
        AccessControl.parsePermissions(encoded),
        {
          WayfinderPermission.manageThemes,
          WayfinderPermission.viewMap,
        },
      );
    });
  });
}
