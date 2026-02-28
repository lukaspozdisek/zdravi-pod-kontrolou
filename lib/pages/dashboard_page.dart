import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';
import 'package:zdravi_pod_kontrolou/widgets/controls/sun_gradient_button.dart';
import 'package:zdravi_pod_kontrolou/widgets/controls/sun_pill_tabs.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  final int sectionIndex; // kept for compatibility with SunShell
  final ValueChanged<int> onSectionChanged; // kept for compatibility

  const DashboardPage({
    super.key,
    required this.sectionIndex,
    required this.onSectionChanged,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int pillIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final genderMode = settings.genderMode;

    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;
    final secondary = cs.secondary;

    final text = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    final muted =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.white70;

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
    final macros = _MacroData(protein: 78, carbs: 65, fat: 42);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Text(
                context.tr('dashboard.greeting'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('dashboard.subtitle'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),

              // ✅ NO carousel on Dashboard

              SunPillTabs(
                items: [
                  context.tr('dashboard.pill.daily'),
                  context.tr('dashboard.pill.weekly'),
                  context.tr('dashboard.pill.stats'),
                ],
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
                          labelBottom: context.tr('dashboard.kcal'),
                          textColor: text,
                          mutedColor: muted,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatLine(
                                label: context.tr('dashboard.stat.protein'),
                                value: context.tr('dashboard.value.grams',
                                    params: {'g': '78'}),
                                color: accent,
                                muted: muted,
                              ),
                              _StatLine(
                                label: context.tr('dashboard.stat.carbs'),
                                value: context.tr('dashboard.value.grams',
                                    params: {'g': '65'}),
                                color: secondary,
                                muted: muted,
                              ),
                              _StatLine(
                                label: context.tr('dashboard.stat.fiber'),
                                value: context.tr('dashboard.value.grams',
                                    params: {'g': '22'}),
                                color: SunColors.success,
                                muted: muted,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Chip(
                                    text: context.tr('dashboard.chip.water',
                                        params: {'cur': '4', 'goal': '8'}),
                                    icon: Icons.water_drop,
                                    color: secondary,
                                  ),
                                  _Chip(
                                    text: context.tr(
                                        'dashboard.chip.injectionIn',
                                        params: {'d': '2'}),
                                    icon: Icons.vaccines,
                                    color: accent,
                                  ),
                                  _Chip(
                                    text: context
                                        .tr('dashboard.chip.mood', params: {
                                      'value': context.tr('dashboard.mood.good')
                                    }),
                                    icon: Icons.emoji_emotions,
                                    color: accent,
                                  ),
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
                    Text(
                      context.tr('dashboard.energyToday'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _GlassChartContainer(
                      child: _LineChart(
                        values: kcalLine,
                        lineColor: accent,
                        gridColor: Theme.of(context).dividerColor,
                        textColor: muted,
                        footerText: context.tr('dashboard.energyRange'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SunGradientButton(
                            label: context.tr('dashboard.action.addFood'),
                            icon: Icons.restaurant,
                            gradient: SunTheme.brandGradient70_30(genderMode),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        _SquareAction(
                          icon: Icons.qr_code_scanner,
                          label: context.tr('dashboard.action.scan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('dashboard.macros'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _GlassChartContainer(
                      child: _StackedMacroBar(
                        data: macros,
                        proteinColor: accent,
                        carbsColor: secondary,
                        fatColor: SunColors.warning,
                        textColor: muted,
                        gridColor: Theme.of(context).dividerColor,
                        footerText: context.tr('dashboard.macrosFooter'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniMetric(
                            label: context.tr('dashboard.stat.protein'),
                            value: context.tr('dashboard.value.grams',
                                params: {'g': '${macros.protein}'}),
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniMetric(
                            label: context.tr('dashboard.stat.carbs'),
                            value: context.tr('dashboard.value.grams',
                                params: {'g': '${macros.carbs}'}),
                            color: secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniMetric(
                            label: context.tr('dashboard.stat.fat'),
                            value: context.tr('dashboard.value.grams',
                                params: {'g': '${macros.fat}'}),
                            color: SunColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('dashboard.thisWeek'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _GlassChartContainer(
                      child: _WeeklyBars(
                        values: weeklyKcal,
                        barColor: accent,
                        textColor: muted,
                        gridColor: Theme.of(context).dividerColor,
                        footerText: context.tr('dashboard.weekdaysShort'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('dashboard.goalKcalPerDay',
                          params: {'kcal': '1500'}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('dashboard.moodQuestion'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MoodTile(
                            emoji: '😊',
                            label: context.tr('dashboard.mood.great')),
                        _MoodTile(
                            emoji: '🙂',
                            label: context.tr('dashboard.mood.good')),
                        _MoodTile(
                            emoji: '😐',
                            label: context.tr('dashboard.mood.neutral')),
                        _MoodTile(
                            emoji: '😴',
                            label: context.tr('dashboard.mood.tired')),
                        _MoodTile(
                            emoji: '😣',
                            label: context.tr('dashboard.mood.stressed')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SunGradientButton(
                        label: context.tr('dashboard.action.saveMood'),
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
            label: context.tr('settings.gender.woman'),
            selected: mode == SunGenderMode.woman,
            color: accent,
            onTap: () => onChanged(SunGenderMode.woman),
          ),
          _SwitchItem(
            label: context.tr('settings.gender.man'),
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

class _LineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final String footerText;

  const _LineChart({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
          values: values, lineColor: lineColor, gridColor: gridColor),
      child: Align(
        alignment: Alignment.bottomLeft,
        child:
            Text(footerText, style: TextStyle(fontSize: 11, color: textColor)),
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

    final path = Path()..moveTo(p(0).dx, p(0).dy);
    for (int i = 1; i < values.length; i++) {
      path.lineTo(p(i).dx, p(i).dy);
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (int i = 0; i < values.length; i++) {
      final pt = p(i);
      canvas.drawCircle(pt, 3.5, dotPaint);
    }

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
  final String footerText;

  const _StackedMacroBar({
    required this.data,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.textColor,
    required this.gridColor,
    required this.footerText,
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
        child:
            Text(footerText, style: TextStyle(fontSize: 11, color: textColor)),
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

    canvas.drawRRect(r, Paint()..color = Colors.white.withOpacity(0.08));

    double x = 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, pW, barHeight), const Radius.circular(14)),
      Paint()..color = proteinColor.withOpacity(0.95),
    );
    x += pW;

    canvas.drawRect(Rect.fromLTWH(x, y, cW, barHeight),
        Paint()..color = carbsColor.withOpacity(0.95));
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
  final Color textColor;
  final Color gridColor;
  final String footerText;

  const _WeeklyBars({
    required this.values,
    required this.barColor,
    required this.textColor,
    required this.gridColor,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeeklyBarsPainter(
          values: values, barColor: barColor, gridColor: gridColor),
      child: Align(
        alignment: Alignment.bottomLeft,
        child:
            Text(footerText, style: TextStyle(fontSize: 11, color: textColor)),
      ),
    );
  }
}

class _WeeklyBarsPainter extends CustomPainter {
  final List<double> values;
  final Color barColor;
  final Color gridColor;

  _WeeklyBarsPainter(
      {required this.values, required this.barColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

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
