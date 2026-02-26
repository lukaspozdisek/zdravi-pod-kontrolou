import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // není nutné
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';

/* ----------------------------- helpers ----------------------------- */

double clampDouble(double v, double min, double max) {
  if (v.isNaN || v.isInfinite) return min;
  if (v < min) return min;
  if (v > max) return max;
  return v;
}

double safeSweep(double raw, {double eps = 0.001}) {
  // pro arc nechceme 0 (nic) ani 2π (artefakt)
  return clampDouble(raw, eps, 2 * math.pi - eps);
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

/* ----------------------------- mini i18n (inline) ----------------------------- */

String t(BuildContext context, String key,
    {Map<String, String> args = const {}}) {
  final base = AppLocalizations.of(context).tr(key);

  var out = base;

  for (final entry in args.entries) {
    out = out.replaceAll('{${entry.key}}', entry.value);
  }

  return out;
}

/* ----------------------------- app ----------------------------- */

class _GLP1DemoScreenState extends State<GLP1DemoScreen> {
  String variant = 'bloom';
  double protein = 85;
  double water = 4;
  int days = 3;
  int mood = 4;
  int cycleDay = 14;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final isWoman = settings.genderMode == SunGenderMode.woman;
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(t(context, 'app.title'),
                    style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300)),
                const SizedBox(height: 6),
                Text(t(context, 'app.subtitle'),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF666666))),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () {},
                    child: Text(
                        'Lang: ${Localizations.localeOf(context).languageCode.toUpperCase()}')),
                const SizedBox(height: 12),
                if (isWoman)
                  GLP1BloomWidget(
                    proteinCurrent: protein,
                    proteinGoal: 120,
                    waterCurrent: water,
                    daysUntilInjection: days,
                    menstrualDay: cycleDay,
                    moodLevel: mood,
                  )
                else
                  GLP1CoreWidget(
                    proteinCurrent: protein,
                    proteinGoal: 120,
                    waterCurrent: water,
                    daysUntilInjection: days,
                    moodLevel: mood,
                  ),
                const SizedBox(height: 28),
                Container(
                  width: 340,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DemoButton(
                              text: t(context, 'demo.woman'),
                              active: variant == 'bloom',
                              onTap: () =>
                                  settings.setGenderMode(SunGenderMode.woman),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DemoButton(
                              text: t(context, 'demo.man'),
                              active: variant == 'core',
                              onTap: () =>
                                  settings.setGenderMode(SunGenderMode.man),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SliderRow(
                        label: t(context, 'demo.protein',
                            args: {'g': '${protein.round()}'}),
                        min: 0,
                        max: 130,
                        value: protein,
                        onChanged: (v) => setState(() => protein = v),
                      ),
                      _SliderRow(
                        label: t(context, 'demo.water',
                            args: {'n': '${water.round()}'}),
                        min: 0,
                        max: 8,
                        divisions: 8,
                        value: water,
                        onChanged: (v) => setState(() => water = v),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(context, 'demo.inj', args: {'d': '$days'}),
                            style: TextStyle(
                              fontSize: 12,
                              color: (days == 0)
                                  ? Colors.redAccent
                                  : const Color(0xFFAAAAAA),
                            ),
                          ),
                          Slider(
                            min: 0,
                            max: 7,
                            divisions: 7,
                            value: days.toDouble(),
                            onChanged: (v) => setState(() => days = v.round()),
                          ),
                          Text(t(context, 'demo.injHint'),
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF666666))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (variant == 'bloom') ...[
                        _SliderRow(
                          label: t(context, 'demo.cycle',
                              args: {'d': '$cycleDay'}),
                          min: 1,
                          max: 28,
                          divisions: 27,
                          value: cycleDay.toDouble(),
                          onChanged: (v) =>
                              setState(() => cycleDay = v.round()),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(t(context, 'demo.mood'),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFAAAAAA))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) {
                          final m = i + 1;
                          Color bg;
                          if (m == 1)
                            bg = const Color(0xFF555555);
                          else if (m == 2)
                            bg = const Color(0xFF444466);
                          else if (m == 3)
                            bg = const Color(0xFF888888);
                          else if (m == 4)
                            bg = const Color(0xFFCC0066);
                          else
                            bg = const Color(0xFF008866);

                          return InkWell(
                            onTap: () => setState(() => mood = m),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (mood == m)
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                  width: (mood == m) ? 2 : 1,
                                ),
                              ),
                              child: Text("$m",
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        }),
                      ),
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

class GLP1DemoScreen extends StatefulWidget {
  const GLP1DemoScreen({super.key});

  @override
  State<GLP1DemoScreen> createState() => _GLP1DemoScreenState();
}

class _DemoButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _DemoButton(
      {required this.text, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF333333) : Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF555555)),
        ),
        child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final int? divisions;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: onChanged,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/* ----------------------------- themes ----------------------------- */

class BloomTheme {
  final Color core;
  final Color bg;
  final Color glow;
  final String moodKey;
  const BloomTheme(
      {required this.core,
      required this.bg,
      required this.glow,
      required this.moodKey});
}

BloomTheme getMoodTheme(int level) {
  if (level == 1)
    return const BloomTheme(
        core: Color(0xFFA3A3FF),
        glow: Color.fromRGBO(120, 120, 255, 0.60),
        moodKey: 'mood.1',
        bg: Color.fromRGBO(40, 30, 60, 1));
  if (level == 2)
    return const BloomTheme(
        core: Color(0xFF4DA6FF),
        glow: Color.fromRGBO(0, 150, 255, 0.60),
        moodKey: 'mood.2',
        bg: Color.fromRGBO(10, 40, 80, 1));
  if (level == 3)
    return const BloomTheme(
        core: Colors.white,
        glow: Color.fromRGBO(255, 255, 255, 0.70),
        moodKey: 'mood.3',
        bg: Color.fromRGBO(50, 40, 60, 1));
  if (level == 4)
    return const BloomTheme(
        core: Color(0xFFFF00DD),
        glow: Color.fromRGBO(255, 0, 220, 0.70),
        moodKey: 'mood.4',
        bg: Color.fromRGBO(60, 0, 40, 1));
  if (level == 5)
    return const BloomTheme(
        core: Color(0xFF00FFE0),
        glow: Color.fromRGBO(0, 255, 220, 0.80),
        moodKey: 'mood.5',
        bg: Color.fromRGBO(0, 50, 50, 1));
  return const BloomTheme(
      core: Color(0xFFFF00DD),
      glow: Color.fromRGBO(255, 0, 220, 0.60),
      moodKey: 'mood.4',
      bg: Colors.black);
}

class CyclePhase {
  final Color color;
  final String key;
  const CyclePhase({required this.color, required this.key});
}

CyclePhase getCyclePhase(int day) {
  if (day <= 5)
    return const CyclePhase(color: Color(0xFFFF0055), key: 'cycle.m');
  if (day <= 13)
    return const CyclePhase(color: Color(0xFFFF99CC), key: 'cycle.f');
  if (day == 14) return const CyclePhase(color: Colors.white, key: 'cycle.o');
  return const CyclePhase(color: Color(0xFFA3A3FF), key: 'cycle.l');
}

class CoreTheme {
  final Color color;
  final Color glow;
  const CoreTheme({required this.color, required this.glow});
}

CoreTheme getCoreTheme(int level) {
  if (level == 1)
    return const CoreTheme(
        color: Color(0xFFFF0000), glow: Color.fromRGBO(255, 0, 0, 0.60));
  if (level == 2)
    return const CoreTheme(
        color: Color(0xFFFF4500), glow: Color.fromRGBO(255, 69, 0, 0.50));
  if (level == 3)
    return const CoreTheme(
        color: Color(0xFFFFCC00), glow: Color.fromRGBO(255, 204, 0, 0.40));
  if (level == 4)
    return const CoreTheme(
        color: Color(0xFF00BFFF), glow: Color.fromRGBO(0, 191, 255, 0.40));
  return const CoreTheme(
      color: Color(0xFF00FF00), glow: Color.fromRGBO(0, 255, 0, 0.50));
}

/* ----------------------------- stars model ----------------------------- */

class Star {
  final double x;
  final double y;
  final double r;
  final double phase;
  final double speed;
  const Star(this.x, this.y, this.r, this.phase, this.speed);
}

List<Star> generateStars(int count, int seed, double size) {
  final rnd = math.Random(seed);
  final out = <Star>[];
  for (int i = 0; i < count; i++) {
    final x = rnd.nextDouble() * size;
    final y = rnd.nextDouble() * size;
    final r = rnd.nextDouble() * 1.8;
    final phase = rnd.nextDouble() * math.pi * 2;
    final speed = 0.6 + rnd.nextDouble() * 1.8;
    out.add(Star(x, y, r, phase, speed));
  }
  return out;
}

/* ----------------------------- BLOOM (woman) ----------------------------- */

class GLP1BloomWidget extends StatefulWidget {
  final double proteinCurrent;
  final double proteinGoal;
  final double waterCurrent;
  final int daysUntilInjection;
  final int menstrualDay;
  final int moodLevel;

  const GLP1BloomWidget({
    super.key,
    this.proteinCurrent = 0,
    this.proteinGoal = 120,
    this.waterCurrent = 0,
    this.daysUntilInjection = 7,
    this.menstrualDay = 1,
    this.moodLevel = 4,
  });

  @override
  State<GLP1BloomWidget> createState() => _GLP1BloomWidgetState();
}

class _GLP1BloomWidgetState extends State<GLP1BloomWidget>
    with TickerProviderStateMixin {
  bool isConfirmed = false;

  late final AnimationController ambientCtrl;
  late final AnimationController flashCtrl;
  late final AnimationController shakeCtrl;
  late final AnimationController injPulseCtrl;

  late final List<Star> stars;

  @override
  void initState() {
    super.initState();
    ambientCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    injPulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    stars = generateStars(15, 12345, 320);
    _syncAnim();
  }

  @override
  void didUpdateWidget(covariant GLP1BloomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysUntilInjection != widget.daysUntilInjection) _syncAnim();
  }

  void _syncAnim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final needsShake = (!isConfirmed && widget.daysUntilInjection == 0);
      final needsPulse = (!isConfirmed &&
          (widget.daysUntilInjection == 0 || widget.daysUntilInjection == 1));

      if (needsShake) {
        if (!shakeCtrl.isAnimating) shakeCtrl.repeat();
      } else {
        if (shakeCtrl.isAnimating) shakeCtrl.stop();
        shakeCtrl.value = 0;
      }

      if (needsPulse) {
        if (!injPulseCtrl.isAnimating) injPulseCtrl.repeat(reverse: true);
      } else {
        if (injPulseCtrl.isAnimating) injPulseCtrl.stop();
        injPulseCtrl.value = 0;
      }
    });
  }

  void _confirm() {
    setState(() => isConfirmed = true);
    flashCtrl.forward(from: 0);
    _syncAnim();
  }

  @override
  void dispose() {
    ambientCtrl.dispose();
    flashCtrl.dispose();
    shakeCtrl.dispose();
    injPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 320.0;
    final theme = getMoodTheme(widget.moodLevel);
    final cycle = getCyclePhase(widget.menstrualDay);

    final isDay0 = (!isConfirmed && widget.daysUntilInjection == 0);

    final inner = isDay0 ? const Color(0xFF3A0000) : theme.bg;
    final outer = Colors.black;

    Color orbitStroke = const Color(0xFFFFD700);
    if (isConfirmed)
      orbitStroke = const Color(0xFF00FFAA);
    else if (widget.daysUntilInjection == 0)
      orbitStroke = const Color(0xFFFF0055);
    else if (widget.daysUntilInjection == 1)
      orbitStroke = const Color(0xFFFF9500);

    final baseShadow = isDay0
        ? const [
            BoxShadow(
                color: Color.fromRGBO(255, 0, 80, 0.60),
                blurRadius: 60,
                spreadRadius: 10),
          ]
        : [
            BoxShadow(color: theme.glow, blurRadius: 80, spreadRadius: 10),
          ];

    return AnimatedBuilder(
      animation: shakeCtrl,
      builder: (context, child) {
        final s = shakeCtrl.value;
        final dx = isDay0 ? (math.sin(s * math.pi * 2) * 2.0) : 0.0;
        final dy = isDay0 ? (math.cos(s * math.pi * 2) * 2.0) : 0.0;
        final rot = isDay0 ? (math.sin(s * math.pi * 2) * 0.01) : 0.0;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(angle: rot, child: child),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              RadialGradient(colors: [inner, outer], stops: const [0.0, 0.8]),
          boxShadow: baseShadow,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([ambientCtrl, injPulseCtrl]),
              builder: (_, __) {
                return CustomPaint(
                  size: const Size(size, size),
                  painter: _BloomPainter(
                    theme: theme,
                    cycle: cycle,
                    proteinCurrent: widget.proteinCurrent,
                    proteinGoal: widget.proteinGoal,
                    waterCurrent: widget.waterCurrent,
                    daysUntilInjection: widget.daysUntilInjection,
                    menstrualDay: widget.menstrualDay,
                    orbitStroke: orbitStroke,
                    isConfirmed: isConfirmed,
                    ambient: ambientCtrl.value,
                    pulse: injPulseCtrl.value,
                    stars: stars,
                  ),
                );
              },
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: flashCtrl,
                builder: (_, __) {
                  if (flashCtrl.value == 0) return const SizedBox.shrink();
                  return Opacity(
                    opacity: 1 - Curves.easeOut.transform(flashCtrl.value),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            _BloomOverlay(
              theme: theme,
              cycle: cycle,
              proteinCurrent: widget.proteinCurrent,
              daysUntilInjection: widget.daysUntilInjection,
              menstrualDay: widget.menstrualDay,
              isConfirmed: isConfirmed,
              onConfirm: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _BloomOverlay extends StatefulWidget {
  final BloomTheme theme;
  final CyclePhase cycle;
  final double proteinCurrent;
  final int daysUntilInjection;
  final int menstrualDay;
  final bool isConfirmed;
  final VoidCallback onConfirm;

  const _BloomOverlay({
    required this.theme,
    required this.cycle,
    required this.proteinCurrent,
    required this.daysUntilInjection,
    required this.menstrualDay,
    required this.isConfirmed,
    required this.onConfirm,
  });

  @override
  State<_BloomOverlay> createState() => _BloomOverlayState();
}

class _BloomOverlayState extends State<_BloomOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulseFastCtrl;

  @override
  void initState() {
    super.initState();
    pulseFastCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _sync();
  }

  void _sync() {
    final enabled = (!widget.isConfirmed && widget.daysUntilInjection == 0);
    if (enabled) {
      if (!pulseFastCtrl.isAnimating) pulseFastCtrl.repeat(reverse: true);
    } else {
      pulseFastCtrl.stop();
      pulseFastCtrl.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _BloomOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConfirmed != widget.isConfirmed ||
        oldWidget.daysUntilInjection != widget.daysUntilInjection) {
      _sync();
    }
  }

  @override
  void dispose() {
    pulseFastCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStats = (widget.daysUntilInjection > 0 || widget.isConfirmed);

    if (showStats) {
      final isD1 = (!widget.isConfirmed && widget.daysUntilInjection == 1);

      final labelColor = widget.isConfirmed
          ? const Color(0xFF00FFAA)
          : isD1
              ? const Color(0xFFFF9500)
              : Colors.white;

      final topLabel = widget.isConfirmed
          ? t(context, 'bloom.confirmed')
          : isD1
              ? t(context, 'bloom.tomorrow')
              : t(context, widget.theme.moodKey);

      final phaseText = t(context, widget.cycle.key);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${widget.proteinCurrent.round()}",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              shadows: [
                Shadow(
                    color: widget.theme.core.withOpacity(0.35), blurRadius: 12)
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(22, -20),
            child: Text("g",
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withOpacity(0.7))),
          ),
          const SizedBox(height: 2),

          // posun nahoru
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              topLabel,
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: labelColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 3),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              "${widget.menstrualDay}. DEN ($phaseText)",
              style:
                  TextStyle(fontSize: 9, color: widget.cycle.color, height: 1),
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: pulseFastCtrl,
      builder: (_, __) {
        final s = lerpDouble(
            1.0, 1.05, Curves.easeInOut.transform(pulseFastCtrl.value));
        return Transform.scale(
          scale: s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t(context, 'bloom.apply'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFFFF0055),
                  shadows: [Shadow(color: Color(0xFFFF0055), blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF0055), Color(0xFFFF5500)]),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(255, 0, 85, 0.8),
                          blurRadius: 20)
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(t(context, 'bloom.confirmBtn'),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BloomPainter extends CustomPainter {
  final BloomTheme theme;
  final CyclePhase cycle;
  final double proteinCurrent;
  final double proteinGoal;
  final double waterCurrent;
  final int daysUntilInjection;
  final int menstrualDay;
  final Color orbitStroke;
  final bool isConfirmed;
  final double ambient;
  final double pulse;
  final List<Star> stars;

  _BloomPainter({
    required this.theme,
    required this.cycle,
    required this.proteinCurrent,
    required this.proteinGoal,
    required this.waterCurrent,
    required this.daysUntilInjection,
    required this.menstrualDay,
    required this.orbitStroke,
    required this.isConfirmed,
    required this.ambient,
    required this.pulse,
    required this.stars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);

    // stars twinkle
    for (final st in stars) {
      final tw = (0.35 +
          0.65 *
              (0.5 +
                  0.5 *
                      math.sin((ambient * math.pi * 2 * st.speed) + st.phase)));
      final p = Paint()..color = Colors.white.withOpacity(0.15 + 0.55 * tw);
      canvas.drawCircle(Offset(st.x, st.y), st.r, p);
    }

    final radiusOrbit = 135.0;
    final radiusCycle = 110.0;
    final radiusProtein = 65.0;

    final proteinPct = (proteinGoal <= 0)
        ? 0.0
        : clampDouble((proteinCurrent / proteinGoal) * 100.0, 0, 100);
    final sweepProtein = (proteinPct / 100) * 2 * math.pi;

    // orbit geometry
    final orbitAngleDeg = ((7 - daysUntilInjection) / 7) * 360.0 - 90.0;
    final orbitAngleRad = orbitAngleDeg * math.pi / 180.0;
    final syringe = Offset(
      c.dx + radiusOrbit * math.cos(orbitAngleRad),
      c.dy + radiusOrbit * math.sin(orbitAngleRad),
    );

    // cycle pearl geometry
    final cycleAngleDeg = (menstrualDay / 28.0) * 360.0 - 90.0;
    final cycleAngleRad = cycleAngleDeg * math.pi / 180.0;
    final moon = Offset(
      c.dx + radiusCycle * math.cos(cycleAngleRad),
      c.dy + radiusCycle * math.sin(cycleAngleRad),
    );

    // orbit track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFFFD700).withOpacity(0.15);
    canvas.drawCircle(c, radiusOrbit, track);

    final needsPulse =
        (!isConfirmed && (daysUntilInjection == 0 || daysUntilInjection == 1));
    final pulseT = needsPulse ? Curves.easeInOut.transform(pulse) : 0.0;

    final arcWidth = needsPulse ? lerpDouble(4, 6, pulseT) : 4.0;
    final glowBlur = needsPulse ? lerpDouble(8, 14, pulseT) : 10.0;
    final glowOpacity = needsPulse ? lerpDouble(0.65, 0.95, pulseT) : 0.85;

    double arcSweep = isConfirmed
        ? 2 * math.pi
        : ((7 - daysUntilInjection) / 7.0) * 2 * math.pi;

    if (arcSweep > 0.01) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcWidth
        ..strokeCap = StrokeCap.round
        ..color = orbitStroke.withOpacity(glowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);

      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcWidth
        ..strokeCap = StrokeCap.round
        ..color = orbitStroke;

      canvas.drawArc(Rect.fromCircle(center: c, radius: radiusOrbit),
          -math.pi / 2, safeSweep(arcSweep, eps: 0.01), false, glowPaint);
      canvas.drawArc(Rect.fromCircle(center: c, radius: radiusOrbit),
          -math.pi / 2, safeSweep(arcSweep, eps: 0.01), false, arcPaint);
    }

    if (!isConfirmed) {
      final angle = orbitAngleRad + math.pi / 2;
      canvas.save();
      canvas.translate(syringe.dx, syringe.dy);
      canvas.rotate(angle);

      final icon = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = orbitStroke;
      final path = Path()
        ..addRect(const Rect.fromLTWH(-3, -6, 6, 12))
        ..moveTo(0, 6)
        ..lineTo(0, 10)
        ..moveTo(-5, -2)
        ..lineTo(5, -2);

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawPath(path, icon);

      final tp = TextPainter(
        text: TextSpan(
          text: "$daysUntilInjection",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: orbitStroke,
            shadows: [
              Shadow(color: orbitStroke.withOpacity(0.9), blurRadius: 12)
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height - 6));
      canvas.restore();
    }

    // cycle track (dashed)
    final cycleTrack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.15);
    final cyclePath = Path()
      ..addOval(Rect.fromCircle(center: c, radius: radiusCycle));
    final pm = cyclePath.computeMetrics().first;
    const dash = 2.0;
    const gap = 4.0;
    double dist = 0;
    while (dist < pm.length) {
      final seg = pm.extractPath(dist, math.min(dist + dash, pm.length));
      canvas.drawPath(seg, cycleTrack);
      dist += dash + gap;
    }

    // mood blur ring
    final blurRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..color = theme.core.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(c, 95, blurRing);

    // ✅ VODA (žena) - vráceno jako dřív
    _paintPetals(canvas, c, waterCurrent);

    // protein base + fill
    final baseRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white.withOpacity(0.18);
    canvas.drawCircle(c, radiusProtein, baseRing);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.core.withOpacity(0.55), Colors.white.withOpacity(0.18)],
      ).createShader(Rect.fromCircle(center: c, radius: radiusProtein));
    canvas.drawCircle(c, radiusProtein, fill);

    // protein progress (glowy)
    if (proteinCurrent > 0) {
      final arcRect = Rect.fromCircle(center: c, radius: radiusProtein);
      final arcSweep = safeSweep(sweepProtein, eps: 0.0005);

      final shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [theme.core.withOpacity(1.0), Colors.white.withOpacity(0.95)],
      ).createShader(arcRect);

      final glowWide = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final glowTight = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final main = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = shader;

      canvas.drawArc(arcRect, -math.pi / 2, arcSweep, false, glowWide);
      canvas.drawArc(arcRect, -math.pi / 2, arcSweep, false, glowTight);
      canvas.drawArc(arcRect, -math.pi / 2, arcSweep, false, main);
    } else {
      final a = 0.10 + 0.20 * (0.5 + 0.5 * math.sin(ambient * math.pi * 2));
      final idle = Paint()..color = Colors.white.withOpacity(a);
      canvas.drawCircle(c, radiusProtein, idle);
    }

    // cycle pearl
    final aura = Paint()
      ..style = PaintingStyle.fill
      ..color = cycle.color.withOpacity(0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(moon, 14, aura);

    final body = Paint()..color = cycle.color;
    final bodyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(moon, 7, body);
    canvas.drawCircle(moon, 7, bodyStroke);
    canvas.drawCircle(moon, 3, Paint()..color = Colors.white);
  }

  // ✅ původní petals styl (stroke active 2 / inactive 0.5, glow jen když active)
  // ✅ ŽENA / BLOOM — VODA (Lístky) — “původní” vzhled (glow+sharp frame jako Core)
  void _paintPetals(Canvas canvas, Offset c, double water) {
    const count = 12;
    final step = 2 * math.pi / count;
    final active = ((water / 8.0) * count).floor().clamp(0, count);

    for (int i = 0; i < count; i++) {
      final isActive = i < active;
      final rot = i * step;

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.translate(-c.dx, -c.dy);

      final path = Path()
        ..moveTo(c.dx, c.dy - 75)
        ..quadraticBezierTo(c.dx + 15, c.dy - 100, c.dx, c.dy - 120)
        ..quadraticBezierTo(c.dx - 15, c.dy - 100, c.dx, c.dy - 75)
        ..close();

      // Gradient je lokální kolem lístku (to je důležitý rozdíl oproti “celé kružnici”)
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = isActive
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFCCFFFF), Color(0xFF00FFFF)],
                stops: [0.0, 0.4, 1.0],
              ).createShader(Rect.fromLTWH(c.dx - 30, c.dy - 130, 60, 80))
            : null
        ..color = isActive ? Colors.white : Colors.black.withOpacity(0.2);

      // Fill glow (zůstává)
      if (isActive) {
        fillPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      }

      // 1) Outer white frame (glow)
      final strokeGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 3.5 : 0.8
        ..color = (isActive ? Colors.white : Colors.white.withOpacity(0.12))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isActive ? 4 : 0);

      // 2) Crisp white frame (sharp)
      final strokeSharp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 1.6 : 0.6
        ..color = (isActive ? Colors.white : Colors.white.withOpacity(0.10));

      canvas.drawPath(path, fillPaint);

      // draw frame like Core: glow + sharp edge
      canvas.drawPath(path, strokeGlow);
      canvas.drawPath(path, strokeSharp);

      // dot (bez cyan glow – přesně jak máš ve snippet)
      final dot = Paint()
        ..color = Colors.white.withOpacity(isActive ? 1.0 : 0.3);
      canvas.drawCircle(Offset(c.dx, c.dy - 105), isActive ? 2 : 1, dot);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) => true;
}

/* ----------------------------- CORE (man) ----------------------------- */

class GLP1CoreWidget extends StatefulWidget {
  final double proteinCurrent;
  final double proteinGoal;
  final double waterCurrent;
  final int daysUntilInjection;
  final int moodLevel;

  const GLP1CoreWidget({
    super.key,
    this.proteinCurrent = 0,
    this.proteinGoal = 120,
    this.waterCurrent = 0,
    this.daysUntilInjection = 7,
    this.moodLevel = 5,
  });

  @override
  State<GLP1CoreWidget> createState() => _GLP1CoreWidgetState();
}

class _GLP1CoreWidgetState extends State<GLP1CoreWidget>
    with TickerProviderStateMixin {
  bool isConfirmed = false;

  late final AnimationController ambientCtrl;
  late final AnimationController flashCtrl;
  late final AnimationController injPulseCtrl;

  late final List<Star> stars;

  @override
  void initState() {
    super.initState();
    ambientCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    injPulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    stars = generateStars(10, 98765, 320);
    _syncAnim();
  }

  @override
  void didUpdateWidget(covariant GLP1CoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysUntilInjection != widget.daysUntilInjection) _syncAnim();
  }

  void _syncAnim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final needsPulse = (!isConfirmed &&
          (widget.daysUntilInjection == 0 || widget.daysUntilInjection == 1));
      if (needsPulse) {
        if (!injPulseCtrl.isAnimating) injPulseCtrl.repeat(reverse: true);
      } else {
        if (injPulseCtrl.isAnimating) injPulseCtrl.stop();
        injPulseCtrl.value = 0;
      }
    });
  }

  void _confirm() {
    setState(() => isConfirmed = true);
    flashCtrl.forward(from: 0);
    _syncAnim();
  }

  @override
  void dispose() {
    ambientCtrl.dispose();
    flashCtrl.dispose();
    injPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 320.0;
    final theme = getCoreTheme(widget.moodLevel);

    final isDay0 = (!isConfirmed && widget.daysUntilInjection == 0);

    Color orbitColor = theme.color;
    String statusLabel =
        t(context, 'core.inj', args: {'d': '${widget.daysUntilInjection}'});

    if (isConfirmed) {
      orbitColor = const Color(0xFF00FF00);
      statusLabel = t(context, 'core.confirmed');
    } else if (widget.daysUntilInjection == 0) {
      orbitColor = const Color(0xFFFF0055);
      statusLabel = t(context, 'core.deploy');
    } else if (widget.daysUntilInjection == 1) {
      orbitColor = const Color(0xFFFF9500);
      statusLabel = t(context, 'core.t24');
    } else if (widget.daysUntilInjection == 2) {
      orbitColor = const Color(0xFFFFCC00);
      statusLabel = t(context, 'core.t48');
    }

    final bgInner =
        isDay0 ? const Color(0xFF3A0000) : theme.glow.withOpacity(0.9);
    final bgOuter = const Color.fromRGBO(10, 10, 15, 1);

    final shadow = isDay0
        ? const [
            BoxShadow(
                color: Color.fromRGBO(255, 0, 0, 0.5),
                blurRadius: 50,
                spreadRadius: 8),
            BoxShadow(
                color: Color.fromRGBO(255, 0, 0, 0.3),
                blurRadius: 30,
                spreadRadius: -10),
          ]
        : [
            BoxShadow(color: theme.glow, blurRadius: 50, spreadRadius: 6),
            const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.9),
                blurRadius: 20,
                spreadRadius: -10),
          ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            RadialGradient(colors: [bgInner, bgOuter], stops: const [0.0, 0.7]),
        boxShadow: shadow,
        border: Border.all(color: const Color(0xFF333333), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([ambientCtrl, injPulseCtrl]),
            builder: (_, __) {
              return CustomPaint(
                size: const Size(size, size),
                painter: _CorePainter(
                  theme: theme,
                  proteinCurrent: widget.proteinCurrent,
                  proteinGoal: widget.proteinGoal,
                  waterCurrent: widget.waterCurrent,
                  daysUntilInjection: widget.daysUntilInjection,
                  orbitColor: orbitColor,
                  isConfirmed: isConfirmed,
                  ambient: ambientCtrl.value,
                  pulse: injPulseCtrl.value,
                  stars: stars,
                ),
              );
            },
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: flashCtrl,
              builder: (_, __) {
                if (flashCtrl.value == 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: 1 - Curves.easeOut.transform(flashCtrl.value),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          _CoreOverlay(
            displayColor: (isConfirmed ? const Color(0xFF00FF00) : theme.color),
            orbitColor: orbitColor,
            proteinCurrent: widget.proteinCurrent,
            proteinGoal: widget.proteinGoal,
            daysUntilInjection: widget.daysUntilInjection,
            isConfirmed: isConfirmed,
            statusLabel: statusLabel,
            onConfirm: _confirm,
          ),
        ],
      ),
    );
  }
}

class _CoreOverlay extends StatefulWidget {
  final Color displayColor;
  final Color orbitColor;
  final double proteinCurrent;
  final double proteinGoal;
  final int daysUntilInjection;
  final bool isConfirmed;
  final String statusLabel;
  final VoidCallback onConfirm;

  const _CoreOverlay({
    required this.displayColor,
    required this.orbitColor,
    required this.proteinCurrent,
    required this.proteinGoal,
    required this.daysUntilInjection,
    required this.isConfirmed,
    required this.statusLabel,
    required this.onConfirm,
  });

  @override
  State<_CoreOverlay> createState() => _CoreOverlayState();
}

class _CoreOverlayState extends State<_CoreOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulseFastCtrl;

  @override
  void initState() {
    super.initState();
    pulseFastCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _sync();
  }

  void _sync() {
    final enabled = (!widget.isConfirmed && widget.daysUntilInjection == 0);
    if (enabled) {
      if (!pulseFastCtrl.isAnimating) pulseFastCtrl.repeat(reverse: true);
    } else {
      pulseFastCtrl.stop();
      pulseFastCtrl.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _CoreOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConfirmed != widget.isConfirmed ||
        oldWidget.daysUntilInjection != widget.daysUntilInjection) {
      _sync();
    }
  }

  @override
  void dispose() {
    pulseFastCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStats = (widget.daysUntilInjection > 0 || widget.isConfirmed);

    final proteinPct = (widget.proteinGoal <= 0)
        ? 0.0
        : clampDouble(
            (widget.proteinCurrent / widget.proteinGoal) * 100.0, 0, 100);

    if (showStats) {
      final grams = widget.proteinCurrent.round();
      final text = grams.toString();
      final len = text.length;

      final fontSize = (len >= 3) ? 34.0 : 36.0;
      final yOffset = (len >= 3) ? 2.0 : 3.0;
      final gBottom = (len >= 3) ? 10.0 : 11.0;
      final letterSpacing = (len >= 3) ? -1.5 : -2.0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, yOffset),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: letterSpacing,
                    color: grams == 0 ? const Color(0xFFAAAAAA) : Colors.white,
                    shadows: [
                      Shadow(
                          color: widget.displayColor.withOpacity(0.55),
                          blurRadius: 10),
                      Shadow(
                          color: widget.displayColor.withOpacity(0.25),
                          blurRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: EdgeInsets.only(bottom: gBottom),
                  child: const Text(
                    "g",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${proteinPct.round()}%",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.displayColor),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: widget.isConfirmed
                      ? const Color(0xFF00FF00)
                      : widget.displayColor),
              color: Colors.black.withOpacity(0.6),
            ),
            child: Text(
              widget.statusLabel,
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: widget.isConfirmed
                      ? const Color(0xFF00FF00)
                      : widget.displayColor),
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: pulseFastCtrl,
      builder: (_, __) {
        final a = 0.6 + 0.4 * Curves.easeInOut.transform(pulseFastCtrl.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t(context, 'core.await'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: const Color(0xFFFF0055).withOpacity(a),
                shadows: const [
                  Shadow(color: Color(0xFFFF0055), blurRadius: 10)
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: widget.onConfirm,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(color: const Color(0xFFFF0055), width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromRGBO(255, 0, 0, 0.6), blurRadius: 15),
                    BoxShadow(
                        color: Color.fromRGBO(255, 0, 0, 0.3),
                        blurRadius: 10,
                        spreadRadius: -6),
                  ],
                ),
                child: Text(
                  t(context, 'core.init'),
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0055),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CorePainter extends CustomPainter {
  final CoreTheme theme;
  final double proteinCurrent;
  final double proteinGoal;
  final double waterCurrent;
  final int daysUntilInjection;
  final Color orbitColor;
  final bool isConfirmed;
  final double ambient;
  final double pulse;
  final List<Star> stars;

  _CorePainter({
    required this.theme,
    required this.proteinCurrent,
    required this.proteinGoal,
    required this.waterCurrent,
    required this.daysUntilInjection,
    required this.orbitColor,
    required this.isConfirmed,
    required this.ambient,
    required this.pulse,
    required this.stars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);

    // subtle grid
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color.fromRGBO(100, 100, 100, 0.10);

    const step = 30.0;
    for (double x = 0; x <= s; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, s), gridPaint);
    }
    for (double y = 0; y <= s; y += step) {
      canvas.drawLine(Offset(0, y), Offset(s, y), gridPaint);
    }

    // stars
    for (final st in stars) {
      final tw = (0.35 +
          0.65 *
              (0.5 +
                  0.5 *
                      math.sin((ambient * math.pi * 2 * st.speed) + st.phase)));
      final p = Paint()..color = Colors.white.withOpacity(0.08 + 0.35 * tw);
      canvas.drawCircle(Offset(st.x, st.y), st.r, p);
    }

    final radiusOrbit = 140.0;
    final radiusProteinOuter = 80.0;
    final radiusProteinInner = 65.0;

    // dashed orbit track
    final orbitTrack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = orbitColor.withOpacity(0.20);

    final trackPath = Path()
      ..addOval(Rect.fromCircle(center: c, radius: radiusOrbit));
    final pm = trackPath.computeMetrics().first;
    const dash = 5.0;
    const gap = 5.0;
    double dist = 0;
    while (dist < pm.length) {
      final seg = pm.extractPath(dist, math.min(dist + dash, pm.length));
      canvas.drawPath(seg, orbitTrack);
      dist += dash + gap;
    }

    // orbit arc
    final needsPulse =
        (!isConfirmed && (daysUntilInjection == 0 || daysUntilInjection == 1));
    final pulseT = needsPulse ? Curves.easeInOut.transform(pulse) : 0.0;

    final arcWidth = needsPulse ? lerpDouble(5, 7, pulseT) : 5.0;
    final blur = needsPulse ? lerpDouble(8, 14, pulseT) : 10.0;

    double arcSweep = isConfirmed
        ? 2 * math.pi
        : ((7 - daysUntilInjection) / 7.0) * 2 * math.pi;

    if (arcSweep > 0.01) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcWidth
        ..strokeCap = StrokeCap.round
        ..color = orbitColor.withOpacity(0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

      final main = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcWidth
        ..strokeCap = StrokeCap.round
        ..color = orbitColor;

      canvas.drawArc(Rect.fromCircle(center: c, radius: radiusOrbit),
          -math.pi / 2, safeSweep(arcSweep, eps: 0.01), false, glow);
      canvas.drawArc(Rect.fromCircle(center: c, radius: radiusOrbit),
          -math.pi / 2, safeSweep(arcSweep, eps: 0.01), false, main);
    }

    // syringe + number
    if (!isConfirmed) {
      final orbitAngleDeg = ((7 - daysUntilInjection) / 7) * 360.0 - 90.0;
      final orbitAngleRad = orbitAngleDeg * math.pi / 180.0;
      final syringe = Offset(
        c.dx + radiusOrbit * math.cos(orbitAngleRad),
        c.dy + radiusOrbit * math.sin(orbitAngleRad),
      );

      final angle = orbitAngleRad + math.pi / 2;
      canvas.save();
      canvas.translate(syringe.dx, syringe.dy);
      canvas.rotate(angle);

      final icon = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = orbitColor;

      final path = Path()
        ..addRect(const Rect.fromLTWH(-4, -8, 8, 16))
        ..moveTo(0, 8)
        ..lineTo(0, 12)
        ..moveTo(-6, -4)
        ..lineTo(6, -4);

      canvas.drawPath(path, icon);

      final tp = TextPainter(
        text: TextSpan(
          text: "$daysUntilInjection",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            color: orbitColor,
            shadows: [
              Shadow(color: orbitColor.withOpacity(0.9), blurRadius: 12)
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height - 6));
      canvas.restore();
    }

    // ✅ VODA (muž) - cells jak předtím
    _paintCells(canvas, c, waterCurrent);

    // protein rings
    canvas.drawCircle(
      c,
      radiusProteinOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF333333),
    );

    final rot = ambient * math.pi * 2;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    canvas.translate(-c.dx, -c.dy);

    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.color.withOpacity(0.6);

    final dashPath = Path()
      ..addOval(Rect.fromCircle(center: c, radius: radiusProteinOuter));
    final pm2 = dashPath.computeMetrics().first;
    const dash2 = 10.0;
    const gap2 = 30.0;
    double d2 = 0;
    while (d2 < pm2.length) {
      final seg = pm2.extractPath(d2, math.min(d2 + dash2, pm2.length));
      canvas.drawPath(seg, dashPaint);
      d2 += dash2 + gap2;
    }
    canvas.restore();

    canvas.drawCircle(
      c,
      radiusProteinInner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = const Color(0xFF111111),
    );

    final pct = (proteinGoal <= 0)
        ? 0.0
        : clampDouble((proteinCurrent / proteinGoal) * 100.0, 0, 100);
    final sweep = (pct / 100) * 2 * math.pi;

    if (proteinCurrent > 0) {
      final shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [theme.color, Colors.white],
      ).createShader(Rect.fromCircle(center: c, radius: radiusProteinInner));

      final prog = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radiusProteinInner),
        -math.pi / 2,
        safeSweep(sweep, eps: 0.0005),
        false,
        prog,
      );
    }

    canvas.drawCircle(c, radiusProteinInner - 10,
        Paint()..color = Colors.black.withOpacity(0.8));
    canvas.drawCircle(
      c,
      radiusProteinInner - 10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF333333),
    );
  }

  // ✅ MUŽ / CORE — VODA (Cells) — definice vzhledu
  void _paintCells(Canvas canvas, Offset c, double water) {
    const count = 16;
    final step = 2 * math.pi / count;
    final active = ((water / 8.0) * count).floor().clamp(0, count);

    for (int i = 0; i < count; i++) {
      final isActive = i < active;
      final rot = i * step;

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.translate(-c.dx, -c.dy);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - 6, c.dy - 115, 12, 20),
        const Radius.circular(2),
      );

      final fill = Paint()
        ..style = PaintingStyle.fill
        ..shader = isActive
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF87CEFA), Color(0xFF00BFFF)],
              ).createShader(rect.outerRect)
            : null
        ..color = isActive ? const Color(0xFF00BFFF) : const Color(0xFF1A1A2E);

      if (isActive)
        fill.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 1 : 0.5
        ..color = isActive ? Colors.white : const Color(0xFF333333);

      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) => true;
}
