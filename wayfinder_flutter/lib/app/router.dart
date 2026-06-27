import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/settings_tab.dart';

final appRouter = GoRouter(
  initialLocation: '/maps',
  observers: [
    _WayfinderNavObserver(),
  ],
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/maps',
    ),
    GoRoute(
      path: '/maps',
      builder: (context, state) {
        AppLogger.logNav.debug('🧭 Route /maps', data: state.uri.toString());
        return MapScreen(
          initialViewport: parseMapViewportFromUri(state.uri),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      redirect: (context, state) {
        final path = state.uri.path;
        if (path == '/settings' || path == '/settings/') {
          return SettingsTab.general.routePath;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: ':tab',
          redirect: (context, state) {
            final slug = state.pathParameters['tab'];
            if (!SettingsTab.isValidSlug(slug)) {
              return SettingsTab.general.routePath;
            }
            return null;
          },
          builder: (context, state) {
            final tab = SettingsTab.fromSlug(state.pathParameters['tab']);
            AppLogger.logNav.debug('🧭 Route ${tab.routePath}');
            return SettingsScreen(tab: tab);
          },
        ),
      ],
    ),
  ],
);

class _WayfinderNavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.logNav.trace(
      '🧭 didPush',
      data: '${previousRoute?.settings.name ?? '(none)'} -> ${route.settings.name ?? route.settings}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.logNav.trace(
      '🧭 didPop',
      data: '${route.settings.name ?? route.settings} -> ${previousRoute?.settings.name ?? '(none)'}',
    );
  }
}
