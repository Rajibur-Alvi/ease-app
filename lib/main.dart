import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'router/router.dart';
import 'services/app_state_provider.dart';
import 'services/chat_provider.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final appState = AppStateProvider();
  final chatProvider = ChatProvider();
  final connectivity = ConnectivityService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: chatProvider),
        ChangeNotifierProvider.value(value: connectivity),
      ],
      child: EaseApp(appState: appState),
    ),
  );
}

class EaseApp extends StatelessWidget {
  final AppStateProvider appState;

  const EaseApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ease',
      theme: EaseTheme.lightTheme,
      routerConfig: createAppRouter(appState),
      debugShowCheckedModeBanner: false,
    );
  }
}
