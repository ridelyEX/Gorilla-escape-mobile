import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/jungle_theme.dart';
import 'features/codex/presentation/screens/codex_screen.dart';
import 'features/dojo/presentation/screens/dojo_screen.dart';
import 'features/photobooth/presentation/screens/photobooth_screen.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: JungleColors.bgDeepJungle,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesStorageProvider.overrideWithValue(storageService),
      ],
      child: const GorillaEscapeCompanionApp(),
    ),
  );
}

class GorillaEscapeCompanionApp extends StatelessWidget {
  const GorillaEscapeCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jungle Party: Gorilimpiadas Companion',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: JungleTheme.darkTheme,
      theme: JungleTheme.darkTheme,
      home: const JungleMainNavigationShell(),
    );
  }
}

class JungleMainNavigationShell extends StatefulWidget {
  const JungleMainNavigationShell({super.key});

  @override
  State<JungleMainNavigationShell> createState() =>
      _JungleMainNavigationShellState();
}

class _JungleMainNavigationShellState extends State<JungleMainNavigationShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    ProfileScreen(),
    CodexScreen(),
    DojoScreen(),
    PhotoboothScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: JungleColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          decoration: BoxDecoration(
            color: JungleColors.cardGlass.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: JungleColors.accentCyan.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: JungleColors.accentCyan,
              unselectedItemColor: JungleColors.textSecondary,
              selectedLabelStyle: JungleTheme.displayStyle(
                fontSize: 12,
                color: JungleColors.accentCyan,
              ),
              unselectedLabelStyle: JungleTheme.bodyStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: JungleColors.textSecondary,
              ),
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events_rounded),
                  label: 'Perfil & Score',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: 'Códice',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sensors_outlined),
                  activeIcon: Icon(Icons.sensors_rounded),
                  label: 'Dojo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined),
                  activeIcon: Icon(Icons.camera_alt_rounded),
                  label: 'Photo Booth',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
