import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SunSectionCarousel extends StatefulWidget {
  /// 3 items visible + halves on both sides
  static const double viewportFraction = 0.28;

  final List<SunSectionMenuItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  /// Center-lock active item (tap animates to center)
  final bool centerLock;

  const SunSectionCarousel({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
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
    final settings = AppScope.of(context);
    final gender = settings.genderMode;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final gradient = SunTheme.brandGradient70_30(gender);
    final accent = SunTheme.accent(gender, brightness);

    final bg = isDark
        ? SunColors.darkCard.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);

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
            ),
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
                  final parallaxX = (kIsWeb
                      ? 0.0
                      : 6.0 *
                          ((1 - t) *
                              (((_pc.page ?? _pc.initialPage.toDouble()) - i)
                                  .clamp(-1.0, 1.0))));
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
  final LinearGradient
      gradient; // kept for consistency (used in glow/aura only)
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

    final neutralFill = (isDark ? Colors.white : Colors.black).withOpacity(
      0.06,
    );
    final neutralStroke = (isDark ? Colors.white : Colors.black).withOpacity(
      0.10,
    );

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
                        blurRadius: kIsWeb ? (8 + (12 * t)) : (10 + (18 * t)),
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
