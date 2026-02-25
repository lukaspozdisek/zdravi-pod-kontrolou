import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';

// =========================
// Premium Pill Tabs (Daily / Weekly / Stats)
// =========================
class SunPillTabs extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  const SunPillTabs({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final gender = settings.genderMode;
    final brightness = Theme.of(context).brightness;
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
                          : (isDark ? Colors.white : Colors.black).withOpacity(
                              0.65,
                            ),
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
