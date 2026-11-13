import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Builds the SoundCraft dark & light [ThemeData] from the token set (§2.2).
/// One source of truth; screens must not restyle ad hoc.
class SoundCraftThemes {
  static const String? fontFamily =
      null; // Bundled font pending owner asset (queue #1).

  static ThemeData dark() => _build(Brightness.dark, SoundCraftColors.dark);

  static ThemeData light() => _build(Brightness.light, SoundCraftColors.light);

  static ThemeData _build(Brightness brightness, SoundCraftColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brandPrimary,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF06130A)
          : Colors.white,
      primaryContainer: c.brandDeep,
      onPrimaryContainer: c.textPrimary,
      secondary: c.brandWarm,
      onSecondary: const Color(0xFF17130B),
      secondaryContainer: c.brandDeep,
      onSecondaryContainer: c.textPrimary,
      tertiary: c.brandActive,
      onTertiary: const Color(0xFF06130A),
      error: c.errorAccent,
      onError: const Color(0xFF2A0A0A),
      surface: c.backgroundSurface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.backgroundElevated,
      surfaceContainerHigh: c.backgroundElevated,
      surfaceContainer: c.backgroundSurface,
      outline: c.outline,
      outlineVariant: c.outline,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: c.backgroundElevated,
      onInverseSurface: c.textPrimary,
      inversePrimary: c.brandDeep,
    );

    final visualDensity = VisualDensity.standard;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      fontFamily: fontFamily,
      visualDensity: visualDensity,
      scaffoldBackgroundColor: c.backgroundMain,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.backgroundMain,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.backgroundElevated,
        indicatorColor: c.brandDeep,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: c.textSecondary,
            fontSize: 12,
            fontFamily: fontFamily,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.brandPrimary
                : c.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.backgroundElevated,
        indicatorColor: c.brandDeep,
        selectedIconTheme: IconThemeData(color: c.brandPrimary),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: c.textSecondary,
          fontFamily: fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.backgroundElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Radii.card),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.backgroundElevated,
        hintStyle: TextStyle(color: c.textTertiary, fontFamily: fontFamily),
        labelStyle: TextStyle(color: c.textSecondary, fontFamily: fontFamily),
        border: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: c.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: c.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: c.brandPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.m,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brandPrimary,
          foregroundColor: brightness == Brightness.dark
              ? const Color(0xFF06130A)
              : Colors.white,
          minimumSize: const Size(0, kMinTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.m,
          ),
          shape: RoundedRectangleBorder(borderRadius: Radii.control),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(0, kMinTouchTarget),
          side: BorderSide(color: c.outline),
          shape: RoundedRectangleBorder(borderRadius: Radii.control),
          textStyle: TextStyle(fontFamily: fontFamily, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brandPrimary,
          minimumSize: const Size(0, kMinTouchTarget),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(kMinTouchTarget, kMinTouchTarget),
          foregroundColor: c.textSecondary,
          focusColor: c.brandDeep,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.brandPrimary,
        inactiveTrackColor: c.outline,
        thumbColor: c.textPrimary,
        overlayColor: c.brandDeep.withValues(alpha: 0.4),
        trackHeight: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.backgroundElevated,
        contentTextStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: fontFamily,
        ),
        actionTextColor: c.brandPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.control),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.backgroundSurface,
        shape: RoundedRectangleBorder(borderRadius: Radii.card),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        contentTextStyle: TextStyle(
          color: c.textSecondary,
          fontFamily: fontFamily,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.backgroundSurface,
        modalBackgroundColor: c.backgroundSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 15,
          fontFamily: fontFamily,
        ),
        subtitleTextStyle: TextStyle(
          color: c.textSecondary,
          fontSize: 13,
          fontFamily: fontFamily,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.backgroundElevated,
        selectedColor: c.brandDeep,
        labelStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: fontFamily,
          fontSize: 13,
        ),
        side: BorderSide(color: c.outline),
        shape: RoundedRectangleBorder(borderRadius: Radii.circular),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.brandPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.textPrimary : c.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.brandPrimary : c.outline,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.outline),
        radius: const Radius.circular(999),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.backgroundHover,
          borderRadius: Radii.control,
        ),
        textStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
      ),
      textTheme: _textTheme(c),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textTertiary,
        indicatorColor: c.brandPrimary,
        dividerColor: c.outline,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 14),
      ),
    );
  }

  static TextTheme _textTheme(SoundCraftColors c) {
    final family = fontFamily;
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        fontFamily: family,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        fontFamily: family,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        fontFamily: family,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        fontFamily: family,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        fontFamily: family,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        fontFamily: family,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: c.textPrimary,
        fontFamily: family,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: c.textPrimary,
        fontFamily: family,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: c.textSecondary,
        fontFamily: family,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
        fontFamily: family,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: c.textSecondary,
        fontFamily: family,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        color: c.textTertiary,
        fontFamily: family,
      ),
    );
  }
}
