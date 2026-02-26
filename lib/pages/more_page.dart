import 'package:flutter/material.dart';

import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final brightness = Theme.of(context).brightness;
    final gender = settings.genderMode;

    final bg = SunTheme.backgroundGradient(gender, brightness);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, 'more.title')),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bg,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              _SettingsCard(colorScheme: cs),
              const SizedBox(height: 14),
              _AboutCard(colorScheme: cs),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SettingsCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final accent = SunTheme.accent(settings.genderMode, brightness);

    final themeMode = settings.themeMode;
    final gender = settings.genderMode;
    final lang = settings.locale.languageCode;

    final cardBg = isDark
        ? SunColors.darkCard.withOpacity(0.85)
        : Colors.white.withOpacity(0.90);

    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);

    final muted = (isDark ? Colors.white : Colors.black)
        .withOpacity(isDark ? 0.70 : 0.65);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(context, 'settings.title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),

          // THEME
          _RowHeader(
            title: t(context, 'settings.theme'),
            subtitle: t(context, 'settings.theme.subtitle'),
            muted: muted,
          ),
          const SizedBox(height: 8),
          _Segment(
            accent: accent,
            isDark: isDark,
            labels: const ['System', 'Light', 'Dark'],
            selectedIndex: themeMode == ThemeMode.system
                ? 0
                : themeMode == ThemeMode.light
                    ? 1
                    : 2,
            onChanged: (i) {
              if (i == 0) settings.setThemeMode(ThemeMode.system);
              if (i == 1) settings.setThemeMode(ThemeMode.light);
              if (i == 2) settings.setThemeMode(ThemeMode.dark);
            },
          ),

          const SizedBox(height: 16),

          // GENDER
          _RowHeader(
            title: t(context, 'settings.gender'),
            subtitle: t(context, 'settings.gender.subtitle'),
            muted: muted,
          ),
          const SizedBox(height: 8),
          _Segment(
            accent: accent,
            isDark: isDark,
            labels: const ['Woman', 'Man'],
            selectedIndex: gender == SunGenderMode.woman ? 0 : 1,
            onChanged: (i) {
              settings.setGenderMode(
                  i == 0 ? SunGenderMode.woman : SunGenderMode.man);
            },
          ),

          const SizedBox(height: 16),

          // LANGUAGE
          _RowHeader(
            title: t(context, 'settings.language'),
            subtitle: t(context, 'settings.language.subtitle'),
            muted: muted,
          ),
          const SizedBox(height: 8),
          _DropdownBox(
            isDark: isDark,
            accent: accent,
            value: lang,
            items: const [
              DropdownMenuItem(value: 'cs', child: Text('Čeština')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) {
              if (v == null) return;
              settings.setLocale(Locale(v));
            },
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AboutCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final cardBg = isDark
        ? SunColors.darkCard.withOpacity(0.78)
        : Colors.white.withOpacity(0.90);

    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);

    final muted = (isDark ? Colors.white : Colors.black)
        .withOpacity(isDark ? 0.70 : 0.65);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(context, 'about.title'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  t(context, 'about.subtitle'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color muted;

  const _RowHeader({
    required this.title,
    required this.subtitle,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color accent;
  final bool isDark;

  const _Segment({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
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
                        color: accent.withOpacity(isDark ? 0.18 : 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.65),
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

class _DropdownBox<T> extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.isDark,
    required this.accent,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = (isDark ? Colors.white : Colors.black).withOpacity(0.06);
    final stroke = (isDark ? Colors.white : Colors.black).withOpacity(0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF121214) : Colors.white,
        ),
      ),
    );
  }
}
