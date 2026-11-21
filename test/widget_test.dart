import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gorilla_escape_companion/core/storage/local_storage_service.dart';
import 'package:gorilla_escape_companion/main.dart';
import 'package:gorilla_escape_companion/features/profile/presentation/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Gorilla Escape Companion smoke test - 4 navigation modules', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesStorageProvider.overrideWithValue(storage),
        ],
        child: const GorillaEscapeCompanionApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GORILIMPIADAS COMPANION'), findsOneWidget);
    expect(find.text('Perfil & Score'), findsOneWidget);
    expect(find.text('Códice'), findsOneWidget);
    expect(find.text('Dojo'), findsOneWidget);
    expect(find.text('Photo Booth'), findsOneWidget);
  });
}
