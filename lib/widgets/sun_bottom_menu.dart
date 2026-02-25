import 'package:flutter/material.dart';
import '../theme/sun_theme.dart';
import '../core/sun_gender_mode.dart';

class SunBottomMenu extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final SunGenderMode genderMode;

  const SunBottomMenu({
    super.key,
    required this.index,
    required this.onChanged,
    required this.genderMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;

    final accent = SunTheme.accent(genderMode, b);

    final menuBg = (b == Brightness.dark)
        ? (theme.bottomNavigationBarTheme.backgroundColor ??
            const Color(0xFF11111E))
        : (theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface);

    final outerBorder = (b == Brightness.dark)
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: menuBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: outerBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(b == Brightness.dark ? 0.25 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _Item(
            active: index == 0,
            label: 'Přehled',
            icon: Icons.dashboard_rounded,
            accent: accent,
            brightness: b,
            onTap: () => onChanged(0),
          ),
          _Item(
            active: index == 1,
            label: 'Deník',
            icon: Icons.book_rounded,
            accent: accent,
            brightness: b,
            onTap: () => onChanged(1),
          ),
          _Item(
            active: index == 2,
            label: 'Core',
            icon: Icons.favorite_rounded,
            accent: accent,
            brightness: b,
            onTap: () => onChanged(2),
          ),
          _Item(
            active: index == 3,
            label: 'Komunita',
            icon: Icons.people_alt_rounded,
            accent: accent,
            brightness: b,
            onTap: () => onChanged(3),
          ),
          _Item(
            active: index == 4,
            label: 'More',
            icon: Icons.more_horiz_rounded,
            accent: accent,
            brightness: b,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final Color accent;
  final Brightness brightness;
  final VoidCallback onTap;

  const _Item({
    required this.active,
    required this.label,
    required this.icon,
    required this.accent,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = (brightness == Brightness.dark)
        ? const Color(0xFF080808)
        : Colors.white;

    final inactiveColor = (brightness == Brightness.dark)
        ? Colors.white.withOpacity(0.60)
        : Colors.black.withOpacity(0.55);

    final activeColor = accent;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: active ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: active ? Border.all(color: accent, width: 1.4) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 22, color: active ? activeColor : inactiveColor),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active ? activeColor : inactiveColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
