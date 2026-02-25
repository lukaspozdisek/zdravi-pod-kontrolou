import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum SunGenderMode { woman, man }

class SunColors {
  // --- Woman palette ---
  static const Color womanAccentDark = Color(0xFFFD00DD);
  static const Color womanAccentLight = Color(0xFFFD00DD);
  static const Color womanSecondaryDark = Color(0xFFFF66F0);
  static const Color womanSecondaryLight = Color(0xFFFF99F5);

  // --- Man palette ---
  static const Color manAccentDark = Color(0xFF00BFFF);
  static const Color manAccentLight = Color(0xFF0284C7);
  static const Color manSecondaryDark = Color(0xFF38BDF8);
  static const Color manSecondaryLight = Color(0xFF3B82F6);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Dark neutrals
  static const Color darkBg0 = Color(0xFF0B0B16);
  static const Color darkSurface = Color(0xFF121220);
  static const Color darkCard = Color(0xFF141428);
  static const Color darkText = Color(0xFFEDEDF7);
  static const Color darkMuted = Color(0xFF9CA3AF);

  // Light neutrals
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF111827);
  static const Color lightMuted = Color(0xFF6B7280);
  static const Color womanBgDark1 = Color(0xFF1B0B5F); // purple
  static const Color manBgDark1 = Color(0xFF071A2F);   // deep blue

  static const Color womanBgLight1 = Color(0xFFFCE7F3); // soft pink tint
  static const Color manBgLight1 = Color(0xFFE0F2FE);   // soft blue tint

// =========================
// Apple-like gender tokens
// =========================

// MAN tokens
static const Color manBgLight = Color(0xFFF6FBFF);
static const Color manBgTintLight = Color(0xFFEFF9FF);
static const Color manBgDark = Color(0xFF070B12);
static const Color manBgTintDark = Color(0xFF071C2D);

static const Color manCardLight = Color(0xFFFFFFFF);
static const Color manCardDark = Color(0xFF101828);

static const Color manStrokeLight = Color(0x14000000); // 8% black
static const Color manStrokeDark = Color(0x14FFFFFF);  // 8% white

// WOMAN tokens
static const Color womanBgLight = Color(0xFFFFF6FD);
static const Color womanBgTintLight = Color(0xFFFFEAF8);
static const Color womanBgDark = Color(0xFF0A0710);
static const Color womanBgTintDark = Color(0xFF2A0F2A);

static const Color womanCardLight = Color(0xFFFFFFFF);
static const Color womanCardDark = Color(0xFF181020);

static const Color womanStrokeLight = Color(0x14000000); // 8% black
static const Color womanStrokeDark = Color(0x14FFFFFF);  // 8% white
}

class SunTheme {

  // ---------- Premium surface helpers ----------
  static Color accent(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanAccentDark : SunColors.womanAccentLight;
    }
    return isDark ? SunColors.manAccentDark : SunColors.manAccentLight;
  }

  

/// Back-compat alias (older code)
static Color accentColor(SunGenderMode gender, Brightness b) => accent(gender, b);

/// 70/30 brand gradient for buttons / highlights
/// Brand gradient 70/30:
/// - Woman: 70% pink -> 30% blue
/// - Man:   70% blue -> 30% pink
static LinearGradient brandGradient70_30(SunGenderMode gender) {
  final pink = SunColors.womanAccentDark; // #FD00DD
  final blue = SunColors.manAccentDark;   // #00BFFF
  if (gender == SunGenderMode.woman) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pink, pink, blue],
      stops: const [0.0, 0.70, 1.0],
    );
  }
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blue, pink],
    stops: const [0.0, 0.70, 1.0],
  );
}
  static Color cardSurface(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanCardDark : SunColors.womanCardLight;
    }
    return isDark ? SunColors.manCardDark : SunColors.manCardLight;
  }

  static Color surfaceStroke(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    if (gender == SunGenderMode.woman) {
      return isDark ? SunColors.womanStrokeDark : SunColors.womanStrokeLight;
    }
    return isDark ? SunColors.manStrokeDark : SunColors.manStrokeLight;
  }

  static List<BoxShadow> surfaceShadow(SunGenderMode gender, Brightness b) {
    final isDark = b == Brightness.dark;
    final a = accent(gender, b);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.32 : 0.08),
        blurRadius: 26,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: a.withOpacity(isDark ? 0.06 : 0.04),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 0),
      ),
    ];
  }


  static ThemeData dark(SunGenderMode gender) {
    final primary = gender == SunGenderMode.woman
        ? SunColors.womanAccentDark
        : SunColors.manAccentDark;

    final secondary = gender == SunGenderMode.woman
        ? SunColors.womanSecondaryDark
        : SunColors.manSecondaryDark;

    final cs = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: SunColors.darkSurface,
      error: SunColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: SunColors.darkBg0,
      cardColor: SunColors.darkCard,
      dividerColor: Colors.white10,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SunColors.darkText,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: SunColors.darkText, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: SunColors.darkText, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: SunColors.darkText),
        bodySmall: TextStyle(color: SunColors.darkMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SunColors.darkText,
          side: BorderSide(color: primary.withOpacity(0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.06),
        selectedColor: primary.withOpacity(0.18),
        side: BorderSide(color: Colors.white.withOpacity(0.10)),
        labelStyle: const TextStyle(color: SunColors.darkText),
        secondaryLabelStyle: const TextStyle(color: SunColors.darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF11111E),
        selectedItemColor: primary,
        unselectedItemColor: SunColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData light(SunGenderMode gender) {
    final primary = gender == SunGenderMode.woman
        ? SunColors.womanAccentLight
        : SunColors.manAccentLight;

    final secondary = gender == SunGenderMode.woman
        ? SunColors.womanSecondaryLight
        : SunColors.manSecondaryLight;

    final cs = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: SunColors.lightSurface,
      error: SunColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: SunColors.lightBg,
      cardColor: SunColors.lightCard,
      dividerColor: const Color(0xFFE9EBF3),
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SunColors.lightText,
        elevation: 0,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: SunColors.lightText, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: SunColors.lightText, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: SunColors.lightText),
        bodySmall: TextStyle(color: SunColors.lightMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SunColors.lightText,
          side: BorderSide(color: primary.withOpacity(0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primary.withOpacity(0.12),
        side: const BorderSide(color: Color(0xFFE9EBF3)),
        labelStyle: const TextStyle(color: SunColors.lightText),
        secondaryLabelStyle: const TextStyle(color: SunColors.lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: SunColors.lightMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  
/// Helper pro background gradient podle gender + brightness
static List<Color> backgroundGradient(SunGenderMode gender, Brightness b) {
  final isDark = b == Brightness.dark;
  if (isDark) {
    return [
      gender == SunGenderMode.man ? SunColors.manBgDark : SunColors.womanBgDark,
      gender == SunGenderMode.man ? SunColors.manBgTintDark : SunColors.womanBgTintDark,
    ];
  } else {
    return [
      gender == SunGenderMode.man ? SunColors.manBgLight : SunColors.womanBgLight,
      gender == SunGenderMode.man ? SunColors.manBgTintLight : SunColors.womanBgTintLight,
    ];
  }
}

}


class SunSectionMenuItem {
  final String label;
  final IconData icon;

  const SunSectionMenuItem({required this.label, required this.icon});
}

class SunSectionCarousel extends StatefulWidget {
  /// 3 items visible + halves on both sides
  static const double viewportFraction = 0.28;

  final List<SunSectionMenuItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final SunGenderMode gender;
  final Brightness brightness;

  /// Center-lock active item (tap animates to center)
  final bool centerLock;

  const SunSectionCarousel({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    required this.gender,
    required this.brightness,
    this.centerLock = true,
  });

  @override
  State<SunSectionCarousel> createState() => _SunSectionCarouselState();
}

class _SunSectionCarouselState extends State<SunSectionCarousel> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController(
      viewportFraction: SunSectionCarousel.viewportFraction,
      initialPage: widget.index,
    );
  }

  @override
  void didUpdateWidget(covariant SunSectionCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _pc.animateToPage(
        widget.index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (!widget.centerLock) return;
    _pc.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  

  bool _snapping = false;

  void _snapToNearest() {
    if (_snapping) return;
    if (!_pc.hasClients) return;
    final page = _pc.page;
    if (page == null) return;
    final target = page.round().clamp(0, widget.items.length - 1);
    final dist = (page - target).abs();
    // Only snap if we're meaningfully between pages
    if (dist < 0.01) return;
    _snapping = true;
    _pc
        .animateToPage(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (mounted) {
            _snapping = false;
          }
        });
  }

  double _easeElastic(double t) {
    // Apple-ish "spring": slightly overshoots near 1.0
    return Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
  }

@override
  Widget build(BuildContext context) {
    final isDark = widget.brightness == Brightness.dark;
    final gradient = SunTheme.brandGradient70_30(widget.gender);
    final accent = SunTheme.accent(widget.gender, widget.brightness);

    final bg = isDark ? SunColors.darkCard.withOpacity(0.75) : Colors.white.withOpacity(0.85);
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.black).withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, 12),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification) {
                _snapToNearest();
              }
              return false;
            },
            child: PageView.builder(
          controller: _pc,
          itemCount: widget.items.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: widget.onChanged,
          itemBuilder: (context, i) {
            final item = widget.items[i];
            return AnimatedBuilder(
              animation: _pc,
              builder: (context, child) {
                double t = 0;
                if (_pc.hasClients && _pc.position.haveDimensions) {
                  final page = _pc.page ?? _pc.initialPage.toDouble();
                  t = (1 - (page - i).abs()).clamp(0.0, 1.0);
                } else {
                  t = (i == widget.index) ? 1.0 : 0.0;
                }

                final tE = _easeElastic(t);
                final scale = 0.88 + (0.30 * tE); // elastic ~118%
                final parallaxX = (kIsWeb ? 0.0 : 6.0 * ((1 - t) * (( (_pc.page ?? _pc.initialPage.toDouble()) - i).clamp(-1.0, 1.0))));
                final liftY = (kIsWeb ? (-2.0 * tE) : -4.0 * tE);
                final opacity = 0.45 + (0.55 * t);

                return Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: RepaintBoundary(
                        child: _SunCircleMenuChip(
                          label: item.label,
                          icon: item.icon,
                          selectedT: t,
                          gradient: gradient,
                          accent: accent,
                          isDark: isDark,
                          onTap: () {
                            _go(i);
                            widget.onChanged(i);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
            ),
          ),
      ),
    );
  }
}

class _SunCircleMenuChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final double selectedT;
  final LinearGradient gradient; // kept for consistency (used in glow/aura only)
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _SunCircleMenuChip({
    required this.label,
    required this.icon,
    required this.selectedT,
    required this.gradient,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = selectedT.clamp(0.0, 1.0);
    final active = t > 0.65;

    final neutralFill =
        (isDark ? Colors.white : Colors.black).withOpacity(0.06);
    final neutralStroke =
        (isDark ? Colors.white : Colors.black).withOpacity(0.10);

    final baseText = isDark ? Colors.white : Colors.black;
    final labelColor = active ? accent : baseText.withOpacity(0.60);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 86,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle button (NO inner gradient; smooth background + accent outline)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    neutralFill,
                    (isDark ? const Color(0xFF080808) : Colors.white),
                    t,
                  ),
                  border: Border.all(
                    color: Color.lerp(neutralStroke, accent, t)!,
                    width: 1.5,
                  ),
                  // Aura / glow (web-lite)
                  boxShadow: [
                    if (t > 0.01)
                      BoxShadow(
                        color: accent.withOpacity(
                          ((isDark ? 0.34 : 0.20) * t) * (kIsWeb ? 0.70 : 1.0),
                        ),
                        blurRadius:
                            kIsWeb ? (8 + (12 * t)) : (10 + (18 * t)),
                        spreadRadius: kIsWeb ? (0.35 * t) : (0.5 * t),
                        offset: const Offset(0, 0),
                      ),
                    if (!kIsWeb && t > 0.85)
                      BoxShadow(
                        color: accent.withOpacity(isDark ? 0.14 : 0.10),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: Color.lerp(labelColor, accent, t)!,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// =========================
// Premium Gradient Button
// =========================
class SunGradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final SunGenderMode gender;
  final Brightness brightness;
  final LinearGradient? gradient;
  final double height;
  final BorderRadius borderRadius;

  const SunGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.gender,
    required this.brightness,
    this.icon,
    this.gradient,
    this.height = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<SunGradientButton> createState() => _SunGradientButtonState();
}

class _SunGradientButtonState extends State<SunGradientButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final accent = SunTheme.accent(widget.gender, widget.brightness);
    final grad = widget.gradient ?? SunTheme.brandGradient70_30(widget.gender);
    final isDark = widget.brightness == Brightness.dark;

    final scale = _pressed ? 0.98 : 1.0;
    final glow = isDark ? 0.30 : 0.18;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(glow),
                blurRadius: 18,
                spreadRadius: 0.5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: widget.borderRadius,
              onTap: () {
                if (!kIsWeb) HapticFeedback.lightImpact();
                widget.onPressed();
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// =========================
// Premium Pill Tabs (Daily / Weekly / Stats)
// =========================
class SunPillTabs extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final SunGenderMode gender;
  final Brightness brightness;

  const SunPillTabs({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    required this.gender,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final accent = SunTheme.accent(gender, brightness);
    final bg = (isDark ? Colors.white : Colors.black).withOpacity(0.06);
    final stroke = (isDark ? Colors.white : Colors.black).withOpacity(0.10);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!kIsWeb) HapticFeedback.selectionClick();
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: active
                      ? (isDark ? const Color(0xFF080808) : Colors.white)
                      : Colors.transparent,
                  border: Border.all(
                    color: active ? accent : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (active)
                      BoxShadow(
                        color: accent.withOpacity(isDark ? 0.20 : 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white : Colors.black).withOpacity(0.65),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
