import 'package:flutter/material.dart';
import '../../theme/sun_theme.dart'; // kvůli SunTheme helperům / gender / accent
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';
import 'package:zdravi_pod_kontrolou/core/app_scope.dart';

// =========================
// Premium Gradient Button
// =========================
class SunGradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final LinearGradient? gradient;
  final double height;
  final BorderRadius borderRadius;

  const SunGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
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
    final settings = AppScope.of(context);
    final gender = settings.genderMode;
    final brightness = Theme.of(context).brightness;

    final accent = SunTheme.accent(gender, brightness);
    final grad = widget.gradient ?? SunTheme.brandGradient70_30(gender);
    final isDark = brightness == Brightness.dark;

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
