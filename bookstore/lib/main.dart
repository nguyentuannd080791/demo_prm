import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  await dependencies.authProvider.restoreSession();
  runApp(App(dependencies: dependencies));
}
