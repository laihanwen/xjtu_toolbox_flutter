import 'package:flutter/material.dart';

import '../../core/app_environment.dart';
import '../migration/migration_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.environment,
    super.key,
  });

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XJTU Toolbox'),
      ),
      body: MigrationDashboard(environment: environment),
    );
  }
}
