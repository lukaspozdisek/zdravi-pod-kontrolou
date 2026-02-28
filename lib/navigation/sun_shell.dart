import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:zdravi_pod_kontrolou/core/app_scope.dart';
import 'package:zdravi_pod_kontrolou/core/sun_gender_mode.dart';
import 'package:zdravi_pod_kontrolou/l10n/app_localizations.dart';
import 'package:zdravi_pod_kontrolou/theme/sun_theme.dart';

import 'package:zdravi_pod_kontrolou/pages/dashboard_page.dart';
import 'package:zdravi_pod_kontrolou/pages/diary_page.dart';
import 'package:zdravi_pod_kontrolou/pages/core_page.dart';
import 'package:zdravi_pod_kontrolou/pages/community_page.dart';
import 'package:zdravi_pod_kontrolou/pages/more_page.dart';

import 'package:zdravi_pod_kontrolou/widgets/sun_bottom_menu.dart';

/// ✅ One global Scaffold:
/// - Apple-like top bar (menu left, theme toggle right)
/// - One Drawer that changes content for every tab AND for Dashboard sections
/// - Pages should NOT create their own Scaffold/drawer/appBar (avoid nested scaffolds)
class SunShell extends StatefulWidget {
  const SunShell({super.key});

  @override
  State<SunShell> createState() => _SunShellState();
}

class _SunShellState extends State<SunShell> {
  int index = 0;
  int diarySectionIndex = 0;
  int communitySectionIndex = 0;

  void _setDiarySection(int i) => setState(() => diarySectionIndex = i);
  void _setCommunitySection(int i) => setState(() => communitySectionIndex = i);

  /// Dashboard top carousel section (Core/Diary/Food/Body/Chat/...)
  int dashboardSectionIndex = 1;

  void _goTab(int i) => setState(() => index = i);
  void _setDashboardSection(int i) => setState(() => dashboardSectionIndex = i);

  String _titleFor(BuildContext context) {
    switch (index) {
      case 0:
        return _dashboardSectionTitle(context, dashboardSectionIndex);
      case 1:
        return context.tr('tab.diary');
      case 2:
        return context.tr('tab.core');
      case 3:
        return context.tr('tab.community');
      case 4:
        return context.tr('tab.more');
      default:
        return context.tr('app.title');
    }
  }

  String _dashboardSectionTitle(BuildContext context, int i) {
    // These are "sub-sections" inside Dashboard (top carousel).
    // If you later localize them, add keys: dashboard.section.core, etc.
    switch (i) {
      case 0:
        return context.tr('dashboard.section.core');
      case 1:
        return context.tr('dashboard.section.diary');
      case 2:
        return context.tr('dashboard.section.food');
      case 3:
        return context.tr('dashboard.section.body');
      case 4:
        return context.tr('dashboard.section.chat');
      default:
        return context.tr('tab.dashboard');
    }
  }

  List<_DrawerEntry> _drawerEntriesFor(BuildContext context) {
    final settings = AppScope.of(context);
    final genderMode = settings.genderMode;

    void closeDrawer() => Navigator.of(context).maybePop();

    final commonBottom = <_DrawerEntry>[
      _DrawerEntry.divider(),
      _DrawerEntry(
        label: context.tr('drawer.toggleTheme'),
        icon: Theme.of(context).brightness == Brightness.dark
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        onTap: () {
          closeDrawer();
          settings.toggleThemeLightDark();
        },
      ),
      _DrawerEntry(
        label: genderMode == SunGenderMode.woman
            ? context.tr('drawer.switchToMan')
            : context.tr('drawer.switchToWoman'),
        icon: Icons.wc_rounded,
        onTap: () {
          closeDrawer();
          settings.setGenderMode(
            genderMode == SunGenderMode.woman
                ? SunGenderMode.man
                : SunGenderMode.woman,
          );
        },
      ),
    ];

    // ✅ Per-tab drawer content (and Dashboard per-section)
    if (index == 0) {
      final section = dashboardSectionIndex;
      final sectionEntries = <_DrawerEntry>[];

      if (section == 0) {
        sectionEntries.addAll([
          _DrawerEntry(
            label: context.tr('drawer.core.overview'),
            icon: Icons.dashboard_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.core.goals'),
            icon: Icons.flag_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.core.insights'),
            icon: Icons.insights_rounded,
            onTap: () => closeDrawer(),
          ),
        ]);
      } else if (section == 1) {
        sectionEntries.addAll([
          _DrawerEntry(
            label: context.tr('drawer.diary.addEntry'),
            icon: Icons.add_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.diary.history'),
            icon: Icons.history_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.diary.templates'),
            icon: Icons.view_list_rounded,
            onTap: () => closeDrawer(),
          ),
        ]);
      } else if (section == 2) {
        sectionEntries.addAll([
          _DrawerEntry(
            label: context.tr('drawer.food.addFood'),
            icon: Icons.restaurant_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.food.scanBarcode'),
            icon: Icons.qr_code_scanner_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.food.favorites'),
            icon: Icons.star_rounded,
            onTap: () => closeDrawer(),
          ),
        ]);
      } else if (section == 3) {
        sectionEntries.addAll([
          _DrawerEntry(
            label: context.tr('drawer.body.measurements'),
            icon: Icons.monitor_weight_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.body.progress'),
            icon: Icons.show_chart_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.body.photos'),
            icon: Icons.photo_library_rounded,
            onTap: () => closeDrawer(),
          ),
        ]);
      } else if (section == 4) {
        sectionEntries.addAll([
          _DrawerEntry(
            label: context.tr('drawer.chat.newChat'),
            icon: Icons.add_comment_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.chat.coach'),
            icon: Icons.support_agent_rounded,
            onTap: () => closeDrawer(),
          ),
          _DrawerEntry(
            label: context.tr('drawer.chat.saved'),
            icon: Icons.bookmark_rounded,
            onTap: () => closeDrawer(),
          ),
        ]);
      }

      // Quick section switchers (inside Dashboard)
      sectionEntries.add(_DrawerEntry.divider());
      sectionEntries.addAll([
        _DrawerEntry.section(
          label: context.tr('dashboard.section.core'),
          active: section == 0,
          onTap: () {
            closeDrawer();
            _setDashboardSection(0);
          },
        ),
        _DrawerEntry.section(
          label: context.tr('dashboard.section.diary'),
          active: section == 1,
          onTap: () {
            closeDrawer();
            _setDashboardSection(1);
          },
        ),
        _DrawerEntry.section(
          label: context.tr('dashboard.section.food'),
          active: section == 2,
          onTap: () {
            closeDrawer();
            _setDashboardSection(2);
          },
        ),
        _DrawerEntry.section(
          label: context.tr('dashboard.section.body'),
          active: section == 3,
          onTap: () {
            closeDrawer();
            _setDashboardSection(3);
          },
        ),
        _DrawerEntry.section(
          label: context.tr('dashboard.section.chat'),
          active: section == 4,
          onTap: () {
            closeDrawer();
            _setDashboardSection(4);
          },
        ),
      ]);

      return [...sectionEntries, ...commonBottom];
    }

    if (index == 1) {
      return [
        _DrawerEntry(
          label: context.tr('drawer.diary.addEntry'),
          icon: Icons.add_rounded,
          onTap: () => closeDrawer(),
        ),
        _DrawerEntry(
          label: context.tr('drawer.diary.history'),
          icon: Icons.history_rounded,
          onTap: () => closeDrawer(),
        ),
        ...commonBottom,
      ];
    }

    if (index == 2) {
      return [
        _DrawerEntry(
          label: context.tr('drawer.core.overview'),
          icon: Icons.dashboard_rounded,
          onTap: () => closeDrawer(),
        ),
        _DrawerEntry(
          label: context.tr('drawer.core.goals'),
          icon: Icons.flag_rounded,
          onTap: () => closeDrawer(),
        ),
        ...commonBottom,
      ];
    }

    if (index == 3) {
      return [
        _DrawerEntry(
          label: context.tr('drawer.community.groups'),
          icon: Icons.groups_rounded,
          onTap: () => closeDrawer(),
        ),
        _DrawerEntry(
          label: context.tr('drawer.community.chat'),
          icon: Icons.forum_rounded,
          onTap: () => closeDrawer(),
        ),
        _DrawerEntry(
          label: context.tr('drawer.community.events'),
          icon: Icons.event_rounded,
          onTap: () => closeDrawer(),
        ),
        _DrawerEntry(
          label: context.tr('drawer.community.members'),
          icon: Icons.people_alt_rounded,
          onTap: () => closeDrawer(),
        ),
        ...commonBottom,
      ];
    }

    // More tab
    return [
      _DrawerEntry(
        label: context.tr('drawer.more.settings'),
        icon: Icons.settings_rounded,
        onTap: () => closeDrawer(),
      ),
      _DrawerEntry(
        label: context.tr('drawer.more.about'),
        icon: Icons.info_rounded,
        onTap: () => closeDrawer(),
      ),
      ...commonBottom,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);

    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    final accent = SunTheme.accent(settings.genderMode, b);

    final bg = (isDark ? Colors.black : Colors.white).withOpacity(0.72);
    final stroke = (isDark ? Colors.white : Colors.black).withOpacity(0.10);

    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.sunny, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _titleFor(context),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._drawerEntriesFor(context).map((e) {
                if (e.type == _DrawerEntryType.divider) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: stroke),
                  );
                }

                final active = e.active;
                final iconColor = active ? accent : null;
                final textColor = active ? accent : null;

                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  leading:
                      e.icon != null ? Icon(e.icon, color: iconColor) : null,
                  title: Text(
                    e.label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  onTap: e.onTap,
                );
              }),
            ],
          ),
        ),
      ),

      // ✅ Apple-like top bar (blur)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Builder(
          builder: (ctx) => ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(22)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  border: Border(bottom: BorderSide(color: stroke, width: 1)),
                ),
                padding: EdgeInsets.only(top: safeTop, left: 12, right: 12),
                child: SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      _TopIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _titleFor(context),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _TopIconButton(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onTap: settings.toggleThemeLightDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: IndexedStack(
        index: index,
        children: [
          DashboardPage(
            sectionIndex: dashboardSectionIndex,
            onSectionChanged: _setDashboardSection,
          ),
          DiaryPage(
            sectionIndex: diarySectionIndex,
            onSectionChanged: _setDiarySection,
          ),
          const CorePage(),
          CommunityPage(
            sectionIndex: communitySectionIndex,
            onSectionChanged: _setCommunitySection,
          ),
          const MorePage(),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: SunBottomMenu(
            index: index,
            onChanged: _goTab,
            genderMode: settings.genderMode,
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        canRequestFocus: false,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

enum _DrawerEntryType { item, divider }

class _DrawerEntry {
  final _DrawerEntryType type;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool active;

  const _DrawerEntry._({
    required this.type,
    this.label = '',
    this.icon,
    this.onTap,
    this.active = false,
  });

  factory _DrawerEntry.divider() =>
      const _DrawerEntry._(type: _DrawerEntryType.divider);

  factory _DrawerEntry({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return _DrawerEntry._(
      type: _DrawerEntryType.item,
      label: label,
      icon: icon,
      onTap: onTap,
      active: active,
    );
  }

  factory _DrawerEntry.section({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return _DrawerEntry._(
      type: _DrawerEntryType.item,
      label: label,
      icon: Icons.circle,
      onTap: onTap,
      active: active,
    );
  }
}
