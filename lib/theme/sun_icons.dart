import 'package:phosphor_flutter/phosphor_flutter.dart';

class SunIcons {
  const SunIcons._();

  // =========================
  // Navigation
  // =========================

  static PhosphorIconData dashboard(bool active) => active
      ? PhosphorIcons.squaresFour(PhosphorIconsStyle.fill)
      : PhosphorIcons.squaresFour();

  static PhosphorIconData diary(bool active) => active
      ? PhosphorIcons.bookOpen(PhosphorIconsStyle.fill)
      : PhosphorIcons.bookOpen();

  static PhosphorIconData community(bool active) => active
      ? PhosphorIcons.users(PhosphorIconsStyle.fill)
      : PhosphorIcons.users();

  static PhosphorIconData more(bool active) => active
      ? PhosphorIcons.dotsThreeOutline(PhosphorIconsStyle.fill)
      : PhosphorIcons.dotsThreeOutline();

  // =========================
  // User / System
  // =========================

  static PhosphorIconData profile(bool active) => active
      ? PhosphorIcons.user(PhosphorIconsStyle.fill)
      : PhosphorIcons.user();

  static PhosphorIconData settings(bool active) => active
      ? PhosphorIcons.gear(PhosphorIconsStyle.fill)
      : PhosphorIcons.gear();

  static PhosphorIconData info(bool active) => active
      ? PhosphorIcons.info(PhosphorIconsStyle.fill)
      : PhosphorIcons.info();

  static final PhosphorIconData back = PhosphorIcons.arrowLeft();
  static final PhosphorIconData close = PhosphorIcons.x();
  static final PhosphorIconData add = PhosphorIcons.plus();
  static final PhosphorIconData edit = PhosphorIcons.pencilSimple();
  static final PhosphorIconData delete = PhosphorIcons.trash();

  // =========================
  // Health / Fitness (optional)
  // =========================

  static PhosphorIconData calories(bool active) => active
      ? PhosphorIcons.fire(PhosphorIconsStyle.fill)
      : PhosphorIcons.fire();

  static PhosphorIconData protein(bool active) => active
      ? PhosphorIcons.drop(PhosphorIconsStyle.fill)
      : PhosphorIcons.drop();

  static PhosphorIconData weight(bool active) => active
      ? PhosphorIcons.barbell(PhosphorIconsStyle.fill)
      : PhosphorIcons.barbell();

  // 'glass' doesn't exist in 2.1.0 -> use cupWater
  static PhosphorIconData water(bool active) => active
      ? PhosphorIcons.drop(PhosphorIconsStyle.fill)
      : PhosphorIcons.drop();

  static PhosphorIconData steps(bool active) => active
      ? PhosphorIcons.footprints(PhosphorIconsStyle.fill)
      : PhosphorIcons.footprints();
}
