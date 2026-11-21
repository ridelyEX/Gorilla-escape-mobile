import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class JungleColors {
  JungleColors._();

  static const Color bgDeepJungle = Color(0xFF071D22);
  static const Color bgCanopy = Color(0xFF0B3432);
  static const Color cardGlass = Color(0xFF0C3437);
  static const Color accentCyan = Color(0xFF26E0CF);
  static const Color accentGold = Color(0xFFFFD13D);
  static const Color alertCoral = Color(0xFFFF786F);
  static const Color textPrimary = Color(0xFFF4FFFE);
  static const Color textSecondary = Color(0xFFA8C4C2);
  static const Color emeraldSuccess = Color(0xFF34E89E);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      bgDeepJungle,
      bgCanopy,
      Color(0xFF06191D),
    ],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF26E0CF), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD13D), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF786F), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class JungleTheme {
  JungleTheme._();

  static TextStyle displayStyle({
    double fontSize = 24,
    Color color = JungleColors.textPrimary,
    double letterSpacing = 0.6,
    double? height,
  }) {
    return GoogleFonts.lilitaOne(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = JungleColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: JungleColors.bgDeepJungle,
      primaryColor: JungleColors.accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: JungleColors.accentCyan,
        secondary: JungleColors.accentGold,
        surface: JungleColors.cardGlass,
        error: JungleColors.alertCoral,
        onPrimary: JungleColors.bgDeepJungle,
        onSecondary: JungleColors.bgDeepJungle,
        onSurface: JungleColors.textPrimary,
        onError: JungleColors.bgDeepJungle,
      ),
      textTheme: TextTheme(
        displayLarge: displayStyle(fontSize: 34),
        displayMedium: displayStyle(fontSize: 28),
        displaySmall: displayStyle(fontSize: 22),
        headlineMedium: displayStyle(fontSize: 20),
        titleLarge: displayStyle(fontSize: 18),
        titleMedium: bodyStyle(fontSize: 16, fontWeight: FontWeight.w800),
        bodyLarge: bodyStyle(fontSize: 15, fontWeight: FontWeight.w600),
        bodyMedium: bodyStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: JungleColors.textSecondary,
        ),
        labelLarge: bodyStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: displayStyle(fontSize: 22),
        iconTheme: const IconThemeData(color: JungleColors.accentCyan),
      ),
      cardTheme: CardThemeData(
        color: JungleColors.cardGlass.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(
            color: JungleColors.accentCyan.withValues(alpha: 0.22),
            width: 1.4,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JungleColors.bgDeepJungle.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: bodyStyle(
          color: JungleColors.textSecondary.withValues(alpha: 0.6),
        ),
        labelStyle: bodyStyle(
          color: JungleColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: JungleColors.accentCyan.withValues(alpha: 0.25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: JungleColors.accentCyan.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: JungleColors.accentCyan,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JungleColors.accentCyan,
          foregroundColor: JungleColors.bgDeepJungle,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: displayStyle(
            fontSize: 16,
            color: JungleColors.bgDeepJungle,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: JungleColors.cardGlass,
        contentTextStyle: bodyStyle(color: JungleColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: JungleColors.accentCyan, width: 1.2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
