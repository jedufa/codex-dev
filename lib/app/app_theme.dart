import 'package:flutter/material.dart';

import '../shared/constants/radii.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.pageTop,
    required this.pageBottom,
    required this.floatingSurface,
    required this.selectedSegment,
    required this.success,
    required this.warning,
    required this.neutral,
  });

  final Color pageTop;
  final Color pageBottom;
  final Color floatingSurface;
  final Color selectedSegment;
  final Color success;
  final Color warning;
  final Color neutral;

  @override
  AppColors copyWith({
    Color? pageTop,
    Color? pageBottom,
    Color? floatingSurface,
    Color? selectedSegment,
    Color? success,
    Color? warning,
    Color? neutral,
  }) {
    return AppColors(
      pageTop: pageTop ?? this.pageTop,
      pageBottom: pageBottom ?? this.pageBottom,
      floatingSurface: floatingSurface ?? this.floatingSurface,
      selectedSegment: selectedSegment ?? this.selectedSegment,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      pageTop: Color.lerp(pageTop, other.pageTop, t)!,
      pageBottom: Color.lerp(pageBottom, other.pageBottom, t)!,
      floatingSurface: Color.lerp(floatingSurface, other.floatingSurface, t)!,
      selectedSegment: Color.lerp(selectedSegment, other.selectedSegment, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF25635B),
    onPrimary: Colors.white,
    secondary: Color(0xFF5E6E8C),
    onSecondary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: Color(0xFFFFFCF6),
    onSurface: Color(0xFF1F2423),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8ED8CC),
    onPrimary: Color(0xFF07312C),
    secondary: Color(0xFFBAC6E4),
    onSecondary: Color(0xFF1E2738),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF181C1B),
    onSurface: Color(0xFFE4EAE7),
  );

  static ThemeData light() => _theme(
    _lightScheme,
    const AppColors(
      pageTop: Color(0xFFF7F2EA),
      pageBottom: Color(0xFFEAF2EF),
      floatingSurface: Color(0xF7FFFCF6),
      selectedSegment: Color(0xFFE2F0EC),
      success: Color(0xFF27AE60),
      warning: Color(0xFFC2811B),
      neutral: Color(0xFF8B949E),
    ),
  );

  static ThemeData dark() => _theme(
    _darkScheme,
    const AppColors(
      pageTop: Color(0xFF16201E),
      pageBottom: Color(0xFF101413),
      floatingSurface: Color(0xF21B2220),
      selectedSegment: Color(0xFF213933),
      success: Color(0xFF71D89A),
      warning: Color(0xFFE3B461),
      neutral: Color(0xFF9CA3AF),
    ),
  );

  static ThemeData _theme(ColorScheme scheme, AppColors colors) {
    return ThemeData(
      fontFamily: 'Roboto',
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.pageBottom,
      extensions: [colors],
      cardTheme: CardThemeData(
        color: colors.floatingSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF202625)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.16),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: scheme.primary, width: 1.3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.floatingSurface,
        indicatorColor: colors.selectedSegment,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
