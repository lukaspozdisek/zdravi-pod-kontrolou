import 'package:flutter/material.dart';

import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:zdravi_pod_kontrolou/widgets/sections/sun_section_carousel.dart';

class CommunityPage extends StatefulWidget {
  final int sectionIndex;
  final ValueChanged<int> onSectionChanged;

  const CommunityPage({
    super.key,
    required this.sectionIndex,
    required this.onSectionChanged,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
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
            // ✅ TOP CIRCULAR MENU (Community sections)
            SunSectionCarousel(
              items: [
                SunSectionMenuItem(
                  label: context.tr('community.section.about'),
                  icon: Icons.info_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.news'),
                  icon: Icons.campaign_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.academy'),
                  icon: Icons.school_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.biohack'),
                  icon: Icons.spa_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.forum'),
                  icon: Icons.forum_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.events'),
                  icon: Icons.event_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.challenges'),
                  icon: Icons.emoji_events_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.hallOfFame'),
                  icon: Icons.workspace_premium_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.magazine'),
                  icon: Icons.menu_book_rounded,
                ),
                SunSectionMenuItem(
                  label: context.tr('community.section.stories'),
                  icon: Icons.auto_stories_rounded,
                ),
              ],
              index: widget.sectionIndex,
              onChanged: widget.onSectionChanged,
            ),

            const SizedBox(height: 16),

            // Placeholder
            Text(
              context.tr('community.placeholder',
                  params: {'section': sectionLabel}),
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
        return context.tr('community.section.about');
      case 1:
        return context.tr('community.section.news');
      case 2:
        return context.tr('community.section.academy');
      case 3:
        return context.tr('community.section.biohack');
      case 4:
        return context.tr('community.section.forum');
      case 5:
        return context.tr('community.section.events');
      case 6:
        return context.tr('community.section.challenges');
      case 7:
        return context.tr('community.section.hallOfFame');
      case 8:
        return context.tr('community.section.magazine');
      case 9:
        return context.tr('community.section.stories');
      default:
        return context.tr('community.title');
    }
  }
}
