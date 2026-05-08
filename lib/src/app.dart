import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:go_router/go_router.dart';

import 'core/app_environment.dart';
import 'features/calendar/school_calendar_screen.dart';
import 'features/home/home_screen.dart';
import 'features/migration/migration_dashboard.dart';
import 'features/profile/profile_screen.dart';
import 'features/services/services_screen.dart';
import 'navigation/app_shell.dart';

class XjtuToolboxApp extends StatelessWidget {
  const XjtuToolboxApp({required this.environment, super.key});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) {
                    return HomeScreen(environment: environment);
                  },
                  routes: [
                    GoRoute(
                      path: 'calendar',
                      builder: (context, state) {
                        return const SchoolCalendarScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/services',
                  builder: (context, state) {
                    return const ServicesScreen();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/migration',
                  builder: (context, state) {
                    return MigrationDashboard(environment: environment);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) {
                    return ProfileScreen(environment: environment);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'XJTU Toolbox',
      debugShowCheckedModeBanner: environment != AppEnvironment.production,
      themeMode: ThemeMode.system,
      theme: FlexThemeData.light(
        scheme: FlexScheme.jungle,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 8,
        subThemesData: const FlexSubThemesData(
          defaultRadius: 8,
          inputDecoratorRadius: 8,
          navigationBarIndicatorRadius: 8,
          chipRadius: 8,
          cardRadius: 8,
        ),
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.jungle,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 12,
        subThemesData: const FlexSubThemesData(
          defaultRadius: 8,
          inputDecoratorRadius: 8,
          navigationBarIndicatorRadius: 8,
          chipRadius: 8,
          cardRadius: 8,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: theme.brightness,
            primaryColor: CupertinoColors.activeBlue,
            scaffoldBackgroundColor: theme.colorScheme.surface,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
