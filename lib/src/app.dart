import 'package:flutter/material.dart';

import 'core/app_environment.dart';
import 'features/home/home_screen.dart';

class XjtuToolboxApp extends StatelessWidget {
  const XjtuToolboxApp({
    required this.environment,
    super.key,
  });

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XJTU Toolbox',
      debugShowCheckedModeBanner: environment != AppEnvironment.production,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: HomeScreen(environment: environment),
    );
  }
}
