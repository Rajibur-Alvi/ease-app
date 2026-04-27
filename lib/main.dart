import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'router/router.dart';
import 'services/app_state_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: const EaseApp(),
    ),
  );
}

class EaseApp extends StatelessWidget {
  const EaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ease - Calm Technology',
      theme: EaseTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
