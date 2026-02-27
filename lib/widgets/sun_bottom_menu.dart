import 'package:flutter/material.dart';

import '../theme/sun_theme.dart';
import '../core/sun_gender_mode.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/sun_icons.dart';

class SunBottomMenu extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final SunGenderMode genderMode;
  final String logoAssetPath;

  const SunBottomMenu({
    super.key,
    required this.index,
    required this.onChanged,
    required this.genderMode,
    this.logoAssetPath = 'assets/branding/logo.png',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final isDark = b == Brightness.dark;

    final accent = SunTheme.accent(genderMode, b);

    // ✅ exactly: dark black, light white (no opacity)
    final barBg = isDark ? Colors.black : Colors.white;

    // keep stroke/shadow tokens if you want “card” look
    final borderColor = SunTheme.surfaceStroke(genderMode, b);
    final shadows = SunTheme.surfaceShadow(genderMode, b);

    final activeText = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white : Colors.black);

    final mutedText = theme.textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    final mutedIcon = mutedText;

    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ===== BAR =====
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: shadows,
              ),
              child: Row(
                children: [
                  _NavItem(
                    active: index == 0,
                    label: context.tr('tab.dashboard'),
                    icon: SunIcons.dashboard(index == 0),
                    accent: accent,
                    activeText: activeText,
                    mutedIcon: mutedIcon,
                    mutedText: mutedText,
                    onTap: () => onChanged(0),
                  ),
                  _NavItem(
                    active: index == 1,
                    label: context.tr('tab.diary'),
                    icon: SunIcons.diary(index == 1),
                    accent: accent,
                    activeText: activeText,
                    mutedIcon: mutedIcon,
                    mutedText: mutedText,
                    onTap: () => onChanged(1),
                  ),
                  const SizedBox(width: 126),
                  _NavItem(
                    active: index == 3,
                    label: context.tr('tab.community'),
                    icon: SunIcons.community(index == 3),
                    accent: accent,
                    activeText: activeText,
                    mutedIcon: mutedIcon,
                    mutedText: mutedText,
                    onTap: () => onChanged(3),
                  ),
                  _NavItem(
                    active: index == 4,
                    label: context.tr('tab.more'),
                    icon: SunIcons.more(index == 4),
                    accent: accent,
                    activeText: activeText,
                    mutedIcon: mutedIcon,
                    mutedText: mutedText,
                    onTap: () => onChanged(4),
                  ),
                ],
              ),
            ),
          ),

          // ===== FLOATING LOGO (transparent always) =====
          Positioned(
            top: -20,
            child: _CenterLogoOnly(
              active: index == 2,
              assetPath: logoAssetPath,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool active;
  final String label;
  final PhosphorIconData icon;

  final Color accent;
  final Color activeText;
  final Color mutedIcon;
  final Color mutedText;

  final VoidCallback onTap;

  const _NavItem({
    required this.active,
    required this.label,
    required this.icon,
    required this.accent,
    required this.activeText,
    required this.mutedIcon,
    required this.mutedText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Variant A: no background, no border for active state
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                icon,
                size: 20,
                color: active ? accent : mutedIcon,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                    color: active ? activeText : mutedText,
                    height: 1.0,
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

class _CenterLogoOnly extends StatelessWidget {
  final bool active;
  final String assetPath;
  final VoidCallback onTap;

  const _CenterLogoOnly({
    required this.active,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = active ? 1.05 : 1.00;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 140,
          height: 140,
          child: Center(
            child: Image.asset(
              assetPath,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
