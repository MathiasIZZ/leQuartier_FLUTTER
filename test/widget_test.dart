import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_quartier/main.dart';

void main() {
  testWidgets('Le Quartier tabs smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that bottom navigation destinations exist
    expect(find.text('Carte'), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Poser un panneau'), findsOneWidget);
  });
}
