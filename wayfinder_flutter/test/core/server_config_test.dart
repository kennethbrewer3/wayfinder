import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/core/server_config.dart';

void main() {
  group('defaultWebUrlForApi', () {
    test('uses API port + 2 for local Serverpod ports', () {
      expect(
        defaultWebUrlForApi('http://192.168.1.10:18080'),
        'http://192.168.1.10:18082',
      );
      expect(
        defaultWebUrlForApi('http://localhost:18080'),
        'http://localhost:18082',
      );
    });

    test('does not invent :445 from https default port', () {
      expect(
        defaultWebUrlForApi('https://wayfinder-api.brewerhomestead.com'),
        'https://wayfinder-web.brewerhomestead.com',
      );
      expect(
        defaultWebUrlForApi('https://wayfinder-api.brewerhomestead.com:443'),
        'https://wayfinder-web.brewerhomestead.com',
      );
    });

    test('maps api. host prefix to web.', () {
      expect(
        defaultWebUrlForApi('https://api.example.com'),
        'https://web.example.com',
      );
    });

    test('keeps same host when no api naming convention', () {
      expect(
        defaultWebUrlForApi('https://maps.example.com'),
        'https://maps.example.com',
      );
    });
  });
}
