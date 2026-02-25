import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

@immutable
class SunTokens extends ThemeExtension<SunTokens> {
  // --- Brand ---
  final Color accent;
  final Color secondary;

  // --- Neutrals / text ---
  final Color bg; // scaffold background
  final Color surface; // generic surface
  final Color card; // card surface
  final Color text;
  final Color textMuted;
  final Color stroke; // hairline border
  final Color divider;

  // --- Status ---
  final Color success;
  final Color warning;
  final Color danger;

  // --- Effects ---
  final List<BoxShadow> shadowSurface;
  final List<BoxShadow> shadowCard;

  // --- Layout tokens ---
  final double rSm;
  final double rMd;
  final double rLg;
  final double rXl;

  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;

  const SunTokens({
    required this.accent,
    required this.secondary,
    required this.bg,
    required this.surface,
    required this.card,
    required this.text,
    required this.textMuted,
    required this.stroke,
    required this.divider,
    required this.success,
    required this.warning,
    required this.danger,
    required this.shadowSurface,
    required this.shadowCard,
    required this.rSm,
    required this.rMd,
    required this.rLg,
    required this.rXl,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
  });

  @override
  SunTokens copyWith({
    Color? accent,
    Color? secondary,
    Color? bg,
    Color? surface,
    Color? card,
    Color? text,
    Color? textMuted,
    Color? stroke,
    Color? divider,
    Color? success,
    Color? warning,
    Color? danger,
    List<BoxShadow>? shadowSurface,
    List<BoxShadow>? shadowCard,
    double? rSm,
    double? rMd,
    double? rLg,
    double? rXl,
    double? s1,
    double? s2,
    double? s3,
    double? s4,
    double? s5,
    double? s6,
  }) {
    return SunTokens(
      accent: accent ?? this.accent,
      secondary: secondary ?? this.secondary,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      stroke: stroke ?? this.stroke,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      shadowSurface: shadowSurface ?? this.shadowSurface,
      shadowCard: shadowCard ?? this.shadowCard,
      rSm: rSm ?? this.rSm,
      rMd: rMd ?? this.rMd,
      rLg: rLg ?? this.rLg,
      rXl: rXl ?? this.rXl,
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      s3: s3 ?? this.s3,
      s4: s4 ?? this.s4,
      s5: s5 ?? this.s5,
      s6: s6 ?? this.s6,
    );
  }

  @override
  SunTokens lerp(ThemeExtension<SunTokens>? other, double t) {
    if (other is! SunTokens) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t)!;

    List<BoxShadow> ls(List<BoxShadow> a, List<BoxShadow> b) {
      final len = a.length < b.length ? a.length : b.length;
      return List.generate(len, (i) {
        final aa = a[i];
        final bb = b[i];
        return BoxShadow(
          color: lc(aa.color, bb.color),
          blurRadius: lerpDouble(aa.blurRadius, bb.blurRadius, t)!,
          spreadRadius: lerpDouble(aa.spreadRadius, bb.spreadRadius, t)!,
          offset: Offset(
            lerpDouble(aa.offset.dx, bb.offset.dx, t)!,
            lerpDouble(aa.offset.dy, bb.offset.dy, t)!,
          ),
        );
      });
    }

    double ld(double a, double b) => lerpDouble(a, b, t)!;

    return SunTokens(
      accent: lc(accent, other.accent),
      secondary: lc(secondary, other.secondary),
      bg: lc(bg, other.bg),
      surface: lc(surface, other.surface),
      card: lc(card, other.card),
      text: lc(text, other.text),
      textMuted: lc(textMuted, other.textMuted),
      stroke: lc(stroke, other.stroke),
      divider: lc(divider, other.divider),
      success: lc(success, other.success),
      warning: lc(warning, other.warning),
      danger: lc(danger, other.danger),
      shadowSurface: ls(shadowSurface, other.shadowSurface),
      shadowCard: ls(shadowCard, other.shadowCard),
      rSm: ld(rSm, other.rSm),
      rMd: ld(rMd, other.rMd),
      rLg: ld(rLg, other.rLg),
      rXl: ld(rXl, other.rXl),
      s1: ld(s1, other.s1),
      s2: ld(s2, other.s2),
      s3: ld(s3, other.s3),
      s4: ld(s4, other.s4),
      s5: ld(s5, other.s5),
      s6: ld(s6, other.s6),
    );
  }
}
