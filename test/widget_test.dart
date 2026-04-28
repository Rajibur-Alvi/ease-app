import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ease_app/services/app_state_provider.dart';
import 'package:ease_app/services/chat_provider.dart';
import 'package:ease_app/services/connectivity_service.dart';
import 'package:ease_app/main.dart';

void main() {
  testWidgets('Ease app renders without crashing', (WidgetTester tester) async {
    final appState = AppStateProvider();
    final chatProvider = ChatProvider();
    final connectivity = ConnectivityService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: chatProvider),
          ChangeNotifierProvider.value(value: connectivity),
        ],
        child: EaseApp(appState: appState),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
