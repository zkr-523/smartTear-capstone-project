import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/design_system.dart';

/// Five-tab shell: Home, History, Trends, Chat, Settings — teal selection + dot above icon.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Material(
        color: SmartTearColors.bgCard,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0x33FFFFFF),
              ),
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        selected: idx == 0,
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        onTap: () => _goBranch(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selected: idx == 1,
                        icon: Icons.history_outlined,
                        selectedIcon: Icons.history_rounded,
                        onTap: () => _goBranch(1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selected: idx == 2,
                        icon: Icons.show_chart_outlined,
                        selectedIcon: Icons.show_chart_rounded,
                        onTap: () => _goBranch(2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selected: idx == 3,
                        icon: Icons.chat_bubble_outline_rounded,
                        selectedIcon: Icons.chat_bubble_rounded,
                        onTap: () => _goBranch(3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selected: idx == 4,
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings_rounded,
                        onTap: () => _goBranch(4),
                      ),
                    ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? SmartTearColors.teal : SmartTearColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 6,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 5 : 0,
                height: selected ? 5 : 0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SmartTearColors.teal,
                ),
              ),
            ),
          ),
          Icon(selected ? selectedIcon : icon, size: 24, color: color),
        ],
      ),
    );
  }
}
