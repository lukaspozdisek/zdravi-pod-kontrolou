import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SunSectionCarousel extends StatefulWidget {
  /// ✅ Controls spacing between ALL items (inactive ↔ inactive too).
  /// Smaller = items closer together (more visible at once).
  /// Larger = more space between items (fewer visible) and edge items hide behind the panel.
  /// Examples: 0.18 tight • 0.20 default • 0.22 roomy • 0.24 wide
  static const double viewportFraction =
      0.24; //- mezery mezi neaktivnim tlacitkem

  final List<SunSectionMenuItem> items;
  final int index;
  final ValueChanged<int> onChanged;
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
  static const double _panelHeight = 92;

  // Extra headroom so the selected item can pop out without being clipped vertically.
  static const double _overflow = 26;

  // ✅ Change this number to control ONLY the gap around the active item (neighbors push away).
  // 12 = subtle, 18 = nice, 26 = big.
  static const double _neighborGap = 18.0; // mezera mezi aktivnim a neaktivnim

  // ✅ How much horizontal inset the carousel has inside the rounded panel.
  // Larger = edge items hide sooner; Smaller = edge items are more visible.
  static const double _hPad = 10.0;

  late final PageController _pc;
  bool _snapping = false;

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

  double _pageEstimate() {
    if (!_pc.hasClients) return _pc.initialPage.toDouble();
    final pos = _pc.positions.isNotEmpty ? _pc.positions.first : null;
    if (pos == null || !pos.haveDimensions) return _pc.initialPage.toDouble();
    final vd = pos.viewportDimension;
    if (vd == 0) return _pc.initialPage.toDouble();
    final denom = vd * _pc.viewportFraction;
    if (denom == 0) return _pc.initialPage.toDouble();
    return pos.pixels / denom;
  }

  void _go(int i) {
    if (!widget.centerLock) return;
    _snapping = true;
    _pc
        .animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    )
        .whenComplete(() {
      if (mounted) _snapping = false;
    });
  }

  void _snapToNearest() {
    if (_snapping) return;
    if (!_pc.hasClients) return;

    final page = _pageEstimate();
    final target = page.round().clamp(0, widget.items.length - 1);
    final dist = (page - target).abs();
    if (dist < 0.01) return;

    _snapping = true;
    _pc
        .animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    )
        .whenComplete(() {
      if (mounted) _snapping = false;
    });
  }

  double _easeElastic(double t) {
    return Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
  }

  Widget _buildItem({
    required SunSectionMenuItem item,
    required int i,
    required LinearGradient gradient,
    required Color accent,
    required bool isDark,
  }) {
    return AnimatedBuilder(
      animation: _pc,
      builder: (context, child) {
        final pageNow = _pageEstimate();
        final hasDims = _pc.hasClients &&
            _pc.positions.isNotEmpty &&
            _pc.positions.first.haveDimensions;

        final t = hasDims
            ? (1 - (pageNow - i).abs()).clamp(0.0, 1.0)
            : (i == widget.index ? 1.0 : 0.0);

        final tE = _easeElastic(t);

        final scale = 0.88 + (0.30 * tE);
        final dir = (pageNow - i).clamp(-1.0, 1.0);
        final dist = (pageNow - i).abs();

        // ✅ Only the immediate neighbors of the SELECTED index get pushed away.
// Use widget.index (your selected tab) so BOTH neighbors move together.
        final isLeftNeighbor = i == widget.index - 1;
        final isRightNeighbor = i == widget.index + 1;

// Drive the gap by the ACTIVE item's progress (smoothly animates while scrolling).
        final activeT = hasDims
            ? (1 - (pageNow - widget.index).abs()).clamp(0.0, 1.0)
            : 1.0;
        final activeE = _easeElastic(activeT);

// ✅ Positive gap value = neighbors move AWAY from active.
// Left neighbor goes left (negative), right neighbor goes right (positive).
        final neighborPush = isLeftNeighbor
            ? (-_neighborGap * activeE)
            : (isRightNeighbor ? (_neighborGap * activeE) : 0.0);

        final parallaxX = kIsWeb ? 0.0 : 6.0 * ((1 - t) * dir);

        // Pop out (vertical), but keep all items vertically centered inside the panel.
        final popY = kIsWeb ? -14.0 : -18.0;
        final liftY = popY * tE;

        final tilt = kIsWeb ? 0.0 : (0.02 * (1 - t) * dir);

        return Center(
          child: Transform.translate(
            // ✅ Horizontal spacing is done by translating neighbors (NO padding → no “shrinking” look).
            offset: Offset(parallaxX + neighborPush, liftY),
            child: Transform.rotate(
              angle: tilt,
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
                    onTap: () => _go(i),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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

    return SizedBox(
      height: _panelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background panel (clipped)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Give the PageView extra height BOTH above and below (vertical pop-out),
          // but CLIP horizontally so edge items hide behind the rounded panel.
          Positioned(
            left: 0,
            right: 0,
            top: -_overflow,
            bottom: -_overflow,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _hPad),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollEndNotification && !_snapping) {
                      _snapToNearest();
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: widget.items.length,
                    physics: kIsWeb
                        ? const ClampingScrollPhysics()
                        : const BouncingScrollPhysics(),
                    onPageChanged: widget.onChanged,
                    itemBuilder: (context, i) {
                      final item = widget.items[i];
                      return _buildItem(
                        item: item,
                        i: i,
                        gradient: gradient,
                        accent: accent,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunCircleMenuChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final double selectedT;
  final LinearGradient gradient;
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

    final theme = Theme.of(context);

    // same tokens as SunBottomMenu
    final activeText = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white : Colors.black);
    final mutedText = theme.textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    final mutedIcon = mutedText;

    // circle neutrals
    final neutralStroke =
        (isDark ? Colors.white : Colors.black).withOpacity(0.10);

    // unified colors
    final labelColor = active ? activeText : mutedText;
    final iconColor = active ? accent : mutedIcon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),

        // ✅ úplně vypne ripple / highlight / hover / focus overlay
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        canRequestFocus: false,

        child: SizedBox(
          width: 86,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== HALO / AURA =====
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        opacity: (0.20 + (0.55 * t)).clamp(0.0, 1.0),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accent.withOpacity(isDark ? 0.45 : 0.28),
                                accent.withOpacity(0.0),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Main circle button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? (isDark ? const Color(0xFF080808) : Colors.white)
                            : Colors.transparent,
                        border: Border.all(
                          color: Color.lerp(neutralStroke, accent, t)!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (t > 0.01)
                            BoxShadow(
                              color: accent.withOpacity(
                                ((isDark ? 0.30 : 0.18) * t) *
                                    (kIsWeb ? 0.70 : 1.0),
                              ),
                              blurRadius:
                                  kIsWeb ? (6 + (10 * t)) : (8 + (14 * t)),
                              spreadRadius: kIsWeb ? (0.20 * t) : (0.30 * t),
                              offset: const Offset(0, 0),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 22,
                          color: Color.lerp(iconColor, accent, t)!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
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
