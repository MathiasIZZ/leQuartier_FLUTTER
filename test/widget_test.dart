import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_quartier/main.dart';

void main() {
  testWidgets('Le Quartier auth gatekeeper smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    // Verify that login screen is shown initially (unauthenticated)
    expect(find.text('Connexion par téléphone'), findsOneWidget);
    expect(find.text('Recevoir le code SMS'), findsOneWidget);
  });
}
