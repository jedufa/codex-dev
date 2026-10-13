import 'dart:io';
import 'package:codex_dev/app/codex_dev_app.dart';
import 'package:codex_dev/services/mock_codex_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DenyNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Network forbidden in simulated demo');
  }
}

void main() {
  testWidgets(
    'demo sends, streams, separates drafts and reconnects without network',
    (tester) async {
      final guard = DenyNetwork();
      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          CodexDevApp(
            apiClient: MockCodexApiClient(
              responseDelay: const Duration(milliseconds: 300),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('SIMULATED DEMO · NO LIVE CODEX CONNECTION'),
          findsOneWidget,
        );
        expect(find.text('C1'), findsOneWidget);
        expect(find.text('C4'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('chat-composer-field')),
          'A fictional garden plan',
        );
        await tester.pump();
        await tester.tap(find.byKey(const Key('chat-send-button')));
        await tester.pump();
        expect(
          find.text('Simulated progress · no tools are running'),
          findsWidgets,
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Simulated reply: your request stays in memory.'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('chat-composer-field')),
          'Draft for C1',
        );
        await tester.tap(find.byKey(const Key('agent-tab-a2')));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextField, 'Draft for C1'), findsNothing);
        await tester.tap(find.byKey(const Key('agent-tab-a')));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextField, 'Draft for C1'), findsOneWidget);
        await tester.tap(find.byTooltip('Demo settings').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('demo-disconnect')));
        await tester.pumpAndSettle();
        expect(find.text('Simulation disconnected'), findsOneWidget);
        await tester.tap(find.byKey(const Key('demo-reconnect')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('open-navigation-drawer')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('navigation-drawer-chat')));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextField, 'Draft for C1'), findsOneWidget);
        expect(
          find.textContaining('Simulated reply: your request stays in memory.'),
          findsOneWidget,
        );
        expect(guard.attempts, 0);
        expect(tester.takeException(), isNull);
      }, guard);
    },
  );
}
