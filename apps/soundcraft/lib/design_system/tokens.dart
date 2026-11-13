import 'package:flutter/material.dart';

/// Centralised SoundCraft design tokens (contract §2.2/§2.3).
/// Hex literals must NOT be scattered across screens — everything goes through
/// this ThemeExtension or [SoundCraftDimens].
@immutable
class SoundCraftColors extends ThemeExtension<SoundCraftColors> {
  const SoundCraftColors({
    required this.backgroundMain,
    required this.backgroundSurface,
    required this.backgroundElevated,
    required this.backgroundHover,
    required this.brandPrimary,
    required this.brandActive,
    required this.brandDeep,
    required this.brandWarm,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.outline,
    required this.success,
    required this.warning,
    required this.errorAccent,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.badgeLocalBg,
    required this.badgeAudiusBg,
    required this.badgeYoutubeBg,
  });

  final Color backgroundMain; // charcoal forest black
  final Color backgroundSurface; // elevated night green
  final Color backgroundElevated; // cards / nav
  final Color backgroundHover;
  final Color brandPrimary; // lively spring green
  final Color brandActive; // selected state only
  final Color brandDeep; // muted accent
  final Color brandWarm; // sparing guitar/wood accent
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color outline;
  final Color success;
  final Color warning;
  final Color errorAccent;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color badgeLocalBg;
  final Color badgeAudiusBg;
  final Color badgeYoutubeBg;

  /// Dark theme palette (default) — contract §2.2 tokens.
  static const dark = SoundCraftColors(
    backgroundMain: Color(0xFF0B100D),
    backgroundSurface: Color(0xFF121A15),
    backgroundElevated: Color(0xFF1B261E),
    backgroundHover: Color(0xFF26372A),
    brandPrimary: Color(0xFF78E64A),
    brandActive: Color(0xFFA5F56C),
    brandDeep: Color(0xFF245A35),
    brandWarm: Color(0xFFE9BF76),
    textPrimary: Color(0xFFF4F7F2),
    textSecondary: Color(0xFFA9B8AD),
    textTertiary: Color(0xFF77897D),
    outline: Color(0xFF304136),
    success: Color(0xFF79D795),
    warning: Color(0xFFF2BF64),
    errorAccent: Color(0xFFF08080),
    skeletonBase: Color(0xFF1B261E),
    skeletonHighlight: Color(0xFF26372A),
    badgeLocalBg: Color(0xFF245A35),
    badgeAudiusBg: Color(0xFF1E3A4A),
    badgeYoutubeBg: Color(0xFF4A2A2A),
  );

  /// Light theme — adapted for WCAG AA while preserving the spring identity.
  static const light = SoundCraftColors(
    backgroundMain: Color(0xFFF6F8F4),
    backgroundSurface: Color(0xFFFFFFFF),
    backgroundElevated: Color(0xFFEFF4EE),
    backgroundHover: Color(0xFFE2EADF),
    brandPrimary: Color(0xFF2E7D32),
    brandActive: Color(0xFF1B5E20),
    brandDeep: Color(0xFF245A35),
    brandWarm: Color(0xFF9A6B2F),
    textPrimary: Color(0xFF131A15),
    textSecondary: Color(0xFF44554A),
    textTertiary: Color(0xFF64766B),
    outline: Color(0xFFC3CFc6),
    success: Color(0xFF2E7D32),
    warning: Color(0xFF9C6F1D),
    errorAccent: Color(0xFFB3453F),
    skeletonBase: Color(0xFFE2EADF),
    skeletonHighlight: Color(0xFFEFF4EE),
    badgeLocalBg: Color(0xFFDDEFE0),
    badgeAudiusBg: Color(0xFFDCEAF2),
    badgeYoutubeBg: Color(0xFFF2DEDE),
  );

  @override
  SoundCraftColors copyWith({
    Color? backgroundMain,
    Color? backgroundSurface,
    Color? backgroundElevated,
    Color? backgroundHover,
    Color? brandPrimary,
    Color? brandActive,
    Color? brandDeep,
    Color? brandWarm,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? outline,
    Color? success,
    Color? warning,
    Color? errorAccent,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? badgeLocalBg,
    Color? badgeAudiusBg,
    Color? badgeYoutubeBg,
  }) {
    return SoundCraftColors(
      backgroundMain: backgroundMain ?? this.backgroundMain,
      backgroundSurface: backgroundSurface ?? this.backgroundSurface,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      backgroundHover: backgroundHover ?? this.backgroundHover,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandActive: brandActive ?? this.brandActive,
      brandDeep: brandDeep ?? this.brandDeep,
      brandWarm: brandWarm ?? this.brandWarm,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      outline: outline ?? this.outline,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      errorAccent: errorAccent ?? this.errorAccent,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      badgeLocalBg: badgeLocalBg ?? this.badgeLocalBg,
      badgeAudiusBg: badgeAudiusBg ?? this.badgeAudiusBg,
      badgeYoutubeBg: badgeYoutubeBg ?? this.badgeYoutubeBg,
    );
  }

  @override
  SoundCraftColors lerp(SoundCraftColors? other, double t) {
    if (other == null) return this;
    return SoundCraftColors(
      backgroundMain: Color.lerp(backgroundMain, other.backgroundMain, t)!,
      backgroundSurface: Color.lerp(
        backgroundSurface,
        other.backgroundSurface,
        t,
      )!,
      backgroundElevated: Color.lerp(
        backgroundElevated,
        other.backgroundElevated,
        t,
      )!,
      backgroundHover: Color.lerp(backgroundHover, other.backgroundHover, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandActive: Color.lerp(brandActive, other.brandActive, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      brandWarm: Color.lerp(brandWarm, other.brandWarm, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      errorAccent: Color.lerp(errorAccent, other.errorAccent, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      badgeLocalBg: Color.lerp(badgeLocalBg, other.badgeLocalBg, t)!,
      badgeAudiusBg: Color.lerp(badgeAudiusBg, other.badgeAudiusBg, t)!,
      badgeYoutubeBg: Color.lerp(badgeYoutubeBg, other.badgeYoutubeBg, t)!,
    );
  }
}

/// Spatial foundation: 8-pt scale with 4-pt micro offsets (§2.3).
abstract final class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;
  static const double vast = 64;
}

/// Radius family (§2.3): 8 small, 12 controls, 16 cards, 20 hero.
abstract final class Radii {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const circular = BorderRadius.all(Radius.circular(999));
  static final card = BorderRadius.circular(l);
  static final control = BorderRadius.circular(m);
  static final hero = BorderRadius.circular(xl);
}

/// Motion durations (§2.3): small 120–180ms, transitions ~200–300ms.
/// (Named ScDurations to avoid clashing with Flutter's material `Durations`.)
abstract final class ScDurations {
  static const small = Duration(milliseconds: 150);
  static const control = Duration(milliseconds: 200);
  static const transition = Duration(milliseconds: 260);
}

/// Minimum interactive target (§2.3/§23.2): 48 logical px.
const double kMinTouchTarget = 48.0;

/// Breakpoints (§2.4/§23): width-driven adaptation, never device-type guesses.
abstract final class Breakpoints {
  static const compactMax = 599;
  static const mediumMax = 1023;
  static bool isCompact(double width) => width <= compactMax;
  static bool isMedium(double width) =>
      width > compactMax && width <= mediumMax;
  static bool isExpanded(double width) => width > mediumMax;
}

/// Responsive grid column count for album/track grids.
int gridColumnsFor(double width) {
  if (width <= Breakpoints.compactMax) return 2;
  if (width <= 767) return 3;
  if (width <= Breakpoints.mediumMax) return 4;
  if (width <= 1439) return 6;
  return 8;
}

/// Content max width on expanded layouts so desktop windows don't stretch
/// feeds into unreadable ribbons (§2.4).
const double kContentMaxWidth = 1100;

extension SoundCraftColorsContext on BuildContext {
  SoundCraftColors get scColors =>
      Theme.of(this).extension<SoundCraftColors>() ?? SoundCraftColors.dark;
}
