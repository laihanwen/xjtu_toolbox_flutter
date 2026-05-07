import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/app_environment.dart';

void main() {
  runApp(
    const XjtuToolboxApp(
      environment: AppEnvironment.migration,
    ),
  );
}
