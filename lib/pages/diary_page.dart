import 'package:flutter/material.dart';

import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:zdravi_pod_kontrolou/widgets/sections/sun_section_carousel.dart';

class DiaryPage extends StatefulWidget {
  final int sectionIndex;
  final ValueChanged<int> onSectionChanged;

  const DiaryPage({
    super.key,
    required this.sectionIndex,
    required this.onSectionChanged,
  });

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  @override
  Widget build(BuildContext context) {
    final sectionLabel = _sectionLabel(context, widget.sectionIndex);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ✅ TOP CIRCULAR MENU (Diary sections)
            SunSectionCarousel(
              items: [
                SunSectionMenuItem(
                  label: context.tr('diary.section.mood'),
                  icon: Icons.emoji_emotions_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('diary.section.food'),
                  icon: Icons.restaurant_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('diary.section.glp1'),
                  icon: Icons.vaccines_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('diary.section.body'),
                  icon: Icons.monitor_weight_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('diary.section.fitness'),
                  icon: Icons.fitness_center_rounded,
                ),
              ],
              index: widget.sectionIndex,
              onChanged: widget.onSectionChanged,
            ),

            const SizedBox(height: 16),

            // Placeholder content for now
            Text(
              context
                  .tr('diary.placeholder', params: {'section': sectionLabel}),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _sectionLabel(BuildContext context, int i) {
    switch (i) {
      case 0:
        return context.tr('diary.section.mood');
      case 1:
        return context.tr('diary.section.food');
      case 2:
        return context.tr('diary.section.glp1');
      case 3:
        return context.tr('diary.section.body');
      case 4:
        return context.tr('diary.section.fitness');
      default:
        return context.tr('diary.title');
    }
  }
}
