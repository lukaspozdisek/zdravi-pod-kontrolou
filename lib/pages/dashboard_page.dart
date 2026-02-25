import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:zdravi_pod_kontrolou/widgets/sun_bottom_menu.dart';
import 'package:zdravi_pod_kontrolou/widgets/controls/sun_gradient_button.dart';
import 'package:zdravi_pod_kontrolou/widgets/controls/sun_pill_tabs.dart';
import 'package:zdravi_pod_kontrolou/widgets/sections/sun_section_carousel.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int sectionIndex = 1;
  int pillIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final genderMode = settings.genderMode;

    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;

    final accent = cs.primary; // global accent from theme
    final secondary = cs.secondary; // global secondary from theme

    final text = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    final muted =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.white70;

    final bg = SunTheme.backgroundGradient(genderMode, brightness);

    // Demo data (jen pro vizuál)
    final kcalLine = <double>[
      120,
      180,
      220,
      260,
      420,
      520,
      610,
      740,
      820,
      910,
      980
    ];
    final weeklyKcal = <double>[1400, 1550, 1200, 1700, 1500, 1320, 980];
    final macros =
        _MacroData(protein: 78, carbs: 65, fat: 42); // fat jen pro vizuál

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Nastavení'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Info'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const SizedBox(),
        actions: [
          IconButton(
            onPressed: settings.toggleThemeLightDark,
            icon: Icon(
              brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
          ),
          const SizedBox(width: 8),
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Good afternoon, Lukas!',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text('Your day at a glance',
                    style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: 14),

// ======================
// TOP CIRCULAR MENU (section carousel)
// ======================
                SunSectionCarousel(
                  items: const [
                    SunSectionMenuItem(label: 'Core', icon: Icons.home_rounded),
                    SunSectionMenuItem(
                        label: 'Diary', icon: Icons.book_rounded),
                    SunSectionMenuItem(
                        label: 'Food', icon: Icons.restaurant_rounded),
                    SunSectionMenuItem(
                        label: 'Body', icon: Icons.fitness_center_rounded),
                    SunSectionMenuItem(
                        label: 'Chat', icon: Icons.forum_rounded),
                  ],
                  index: sectionIndex,
                  onChanged: (i) => setState(() => sectionIndex = i),
                ),

                const SizedBox(height: 12),

// ======================
// PILL SWITCH (Daily / Weekly / Stats)
// ======================
                SunPillTabs(
                  items: const ['Daily', 'Weekly', 'Stats'],
                  index: pillIndex,
                  onChanged: (i) => setState(() => pillIndex = i),
                ),

                const SizedBox(height: 12),
                _RowGenderSwitch(
                  mode: genderMode,
                  accent: accent,
                  onChanged: settings.setGenderMode,
                ),
                const SizedBox(height: 16),

                // ======================
                // MAIN SUMMARY CARD
                // ======================
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Ring(
                            size: 112,
                            progress: 0.62,
                            accent: accent,
                            labelTop: '980',
                            labelBottom: 'kcal',
                            textColor: text,
                            mutedColor: muted,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatLine(
                                    label: 'Protein',
                                    value: '78 g',
                                    color: accent,
                                    muted: muted),
                                _StatLine(
                                    label: 'Carbs',
                                    value: '65 g',
                                    color: secondary,
                                    muted: muted),
                                _StatLine(
                                    label: 'Fiber',
                                    value: '22 g',
                                    color: SunColors.success,
                                    muted: muted),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _Chip(
                                        text: 'Water 4/8',
                                        icon: Icons.water_drop,
                                        color: secondary),
                                    _Chip(
                                        text: 'Injection in 2d',
                                        icon: Icons.vaccines,
                                        color: accent),
                                    _Chip(
                                        text: 'Mood: Good',
                                        icon: Icons.emoji_emotions,
                                        color: accent),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 14),
                      Divider(color: Theme.of(context).dividerColor),

                      const SizedBox(height: 12),
                      Text('Energy today',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),

                      // Line chart (kcal over day)
                      _GlassChartContainer(
                        child: _LineChart(
                          values: kcalLine,
                          lineColor: accent,
                          gridColor: Theme.of(context).dividerColor,
                          textColor: muted,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SunGradientButton(
                              label: 'Add food',
                              icon: Icons.restaurant,
                              gradient: SunTheme.brandGradient70_30(genderMode),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SquareAction(
                              icon: Icons.qr_code_scanner, label: 'Scan'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ======================
                // MACROS CARD
                // ======================
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Macros',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),

                      // Stacked bar
                      _GlassChartContainer(
                        child: _StackedMacroBar(
                          data: macros,
                          proteinColor: accent,
                          carbsColor: secondary,
                          fatColor: SunColors.warning,
                          textColor: muted,
                          gridColor: Theme.of(context).dividerColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // quick macro pills
                      Row(
                        children: [
                          Expanded(
                              child: _MiniMetric(
                                  label: 'Protein',
                                  value: '${macros.protein}g',
                                  color: accent)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MiniMetric(
                                  label: 'Carbs',
                                  value: '${macros.carbs}g',
                                  color: secondary)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MiniMetric(
                                  label: 'Fat',
                                  value: '${macros.fat}g',
                                  color: SunColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ======================
                // WEEKLY CARD
                // ======================
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This week',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      _GlassChartContainer(
                        child: _WeeklyBars(
                          values: weeklyKcal,
                          barColor: accent,
                          accent: accent,
                          textColor: muted,
                          gridColor: Theme.of(context).dividerColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Goal: 1500 kcal/day',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ======================
                // MOOD CARD
                // ======================
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How do you feel today?',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _MoodTile(emoji: '😊', label: 'Great'),
                          _MoodTile(emoji: '🙂', label: 'Good'),
                          _MoodTile(emoji: '😐', label: 'Neutral'),
                          _MoodTile(emoji: '😴', label: 'Tired'),
                          _MoodTile(emoji: '😣', label: 'Stressed'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SunGradientButton(
                          label: 'Save mood',
                          icon: Icons.save,
                          gradient: SunTheme.brandGradient70_30(genderMode),
                          onPressed: () {},
                        ),
                      )
                    ],
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

/* =========================
   Helpers / UI atoms
========================= */

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GlassChartContainer extends StatelessWidget {
  final Widget child;
  const _GlassChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.22) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
      ),
      child: child,
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final double progress;
  final Color accent;
  final String labelTop;
  final String labelBottom;
  final Color textColor;
  final Color mutedColor;

  const _Ring({
    required this.size,
    required this.progress,
    required this.accent,
    required this.labelTop,
    required this.labelBottom,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, accent: accent),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(labelTop,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
              Text(labelBottom,
                  style: TextStyle(fontSize: 12, color: mutedColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color accent;

  _RingPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withOpacity(0.12)
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = accent
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final start = -math.pi / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
        sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color muted;

  const _StatLine(
      {required this.label,
      required this.value,
      required this.color,
      required this.muted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: muted))),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _Chip({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(text),
      side: Theme.of(context).chipTheme.side,
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  final String emoji;
  final String label;

  const _MoodTile({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 78,
      height: 86,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SquareAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 64,
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/* =========================
   Gender switch
========================= */

class _RowGenderSwitch extends StatelessWidget {
  final SunGenderMode mode;
  final Color accent;
  final ValueChanged<SunGenderMode> onChanged;

  const _RowGenderSwitch({
    required this.mode,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE9EBF3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SwitchItem(
            label: 'Woman',
            selected: mode == SunGenderMode.woman,
            color: accent,
            onTap: () => onChanged(SunGenderMode.woman),
          ),
          _SwitchItem(
            label: 'Man',
            selected: mode == SunGenderMode.man,
            color: accent,
            onTap: () => onChanged(SunGenderMode.man),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SwitchItem({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? color : Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/* =========================
   Charts (no packages)
========================= */

class _LineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  const _LineChart({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        values: values,
        lineColor: lineColor,
        gridColor: gridColor,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text('09:00  →  21:00',
            style: TextStyle(fontSize: 11, color: textColor)),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;

  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // grid lines
    final gridPaint = Paint()
      ..color = gridColor.withOpacity(0.35)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (values.isEmpty) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);

    Offset p(int i) {
      final x = (i / (values.length - 1)) * w;
      final y = h - ((values[i] - minV) / range) * (h - 16);
      return Offset(x, y);
    }

    // line path
    final path = Path()..moveTo(p(0).dx, p(0).dy);
    for (int i = 1; i < values.length; i++) {
      path.lineTo(p(i).dx, p(i).dy);
    }

    // stroke
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // dots
    final dotPaint = Paint()..color = lineColor;
    for (int i = 0; i < values.length; i++) {
      final pt = p(i);
      canvas.drawCircle(pt, 3.5, dotPaint);
    }

    // subtle fill
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = lineColor.withOpacity(0.12);

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _MacroData {
  final int protein;
  final int carbs;
  final int fat;
  const _MacroData(
      {required this.protein, required this.carbs, required this.fat});
}

class _StackedMacroBar extends StatelessWidget {
  final _MacroData data;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final Color textColor;
  final Color gridColor;

  const _StackedMacroBar({
    required this.data,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StackedMacroBarPainter(
        data: data,
        proteinColor: proteinColor,
        carbsColor: carbsColor,
        fatColor: fatColor,
        gridColor: gridColor,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text('Protein / Carbs / Fat',
            style: TextStyle(fontSize: 11, color: textColor)),
      ),
    );
  }
}

class _StackedMacroBarPainter extends CustomPainter {
  final _MacroData data;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final Color gridColor;

  _StackedMacroBarPainter({
    required this.data,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // baseline grid
    final gridPaint = Paint()
      ..color = gridColor.withOpacity(0.35)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, h - 22), Offset(w, h - 22), gridPaint);

    final total = (data.protein + data.carbs + data.fat).toDouble();
    final pW = (data.protein / total) * w;
    final cW = (data.carbs / total) * w;
    final fW = (data.fat / total) * w;

    final barHeight = 24.0;
    final y = (h / 2) - (barHeight / 2);

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, y, w, barHeight),
      const Radius.circular(14),
    );

    // background
    canvas.drawRRect(
      r,
      Paint()..color = Colors.white.withOpacity(0.08),
    );

    // segments
    double x = 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, pW, barHeight), const Radius.circular(14)),
      Paint()..color = proteinColor.withOpacity(0.95),
    );
    x += pW;

    canvas.drawRect(
      Rect.fromLTWH(x, y, cW, barHeight),
      Paint()..color = carbsColor.withOpacity(0.95),
    );
    x += cW;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, fW, barHeight), const Radius.circular(14)),
      Paint()..color = fatColor.withOpacity(0.95),
    );
  }

  @override
  bool shouldRepaint(covariant _StackedMacroBarPainter oldDelegate) => false;
}

class _WeeklyBars extends StatelessWidget {
  final List<double> values;
  final Color barColor;
  final Color accent;
  final Color textColor;
  final Color gridColor;

  const _WeeklyBars({
    required this.values,
    required this.barColor,
    required this.accent,
    required this.textColor,
    required this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeeklyBarsPainter(
        values: values,
        barColor: barColor,
        gridColor: gridColor,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text('Mon  Tue  Wed  Thu  Fri  Sat  Sun',
            style: TextStyle(fontSize: 11, color: textColor)),
      ),
    );
  }
}

class _WeeklyBarsPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final Color gridColor;

  _WeeklyBarsPainter({
    required this.values,
    required this.barColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // grid
    final gridPaint = Paint()
      ..color = gridColor.withOpacity(0.35)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (values.isEmpty) return;

    final maxV = values.reduce(math.max);
    final barCount = values.length;
    final gap = 8.0;
    final barW = (w - gap * (barCount - 1)) / barCount;

    for (int i = 0; i < barCount; i++) {
      final v = values[i];
      final barH = (v / maxV) * (h - 18);
      final x = i * (barW + gap);
      final y = h - barH;

      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, barH),
        const Radius.circular(10),
      );

      canvas.drawRRect(r, Paint()..color = barColor.withOpacity(0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarsPainter oldDelegate) => false;
}
