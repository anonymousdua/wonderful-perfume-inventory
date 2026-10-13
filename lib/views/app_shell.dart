import 'package:flutter/material.dart';

import '../routes/route_generator.dart';
import '../theme/app_theme.dart';

/// Keeps the sidebar fixed. Only the content area (a nested Navigator)
/// changes when a menu item is tapped.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.title});

  final String title;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

class _ShellObserver extends NavigatorObserver {
  _ShellObserver(this.current);
  final ValueNotifier<String> current;

  void _set(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;
    // Defer so listeners don't rebuild in the middle of a build.
    WidgetsBinding.instance.addPostFrameCallback((_) => current.value = name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);
}

class _AppShellState extends State<AppShell> {
  final _navKey = GlobalKey<NavigatorState>();
  final _current = ValueNotifier<String>(RouteGenerator.inventory);
  late final _ShellObserver _observer = _ShellObserver(_current);

  static const _items = [
    _NavItem('Inventory', Icons.inventory_2_outlined, RouteGenerator.inventory),
    _NavItem('Sales', Icons.receipt_long_outlined, RouteGenerator.sales),
    _NavItem(
      'Add Seller',
      Icons.person_add_alt_outlined,
      RouteGenerator.addSeller,
    ),
    _NavItem(
      'Add Perfume',
      Icons.add_circle_outline,
      RouteGenerator.addPerfume,
    ),
  ];

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  void _go(String route) {
    if (_current.value == route) return;
    _navKey.currentState?.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            title: widget.title,
            items: _items,
            current: _current,
            onSelect: _go,
          ),
          Expanded(
            child: Navigator(
              key: _navKey,
              initialRoute: RouteGenerator.inventory,
              onGenerateRoute: RouteGenerator.generateShellRoute,
              observers: [_observer],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.title,
    required this.items,
    required this.current,
    required this.onSelect,
  });

  final String title;
  final List<_NavItem> items;
  final ValueNotifier<String> current;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      // width: 290,
      color: AppColors.plum,
      padding: const EdgeInsets.fromLTRB(18, 36, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.heading(28).copyWith(color: Colors.white),
                    children: const [
                      TextSpan(text: 'Wonderful '),
                      TextSpan(
                        text: 'Perfumes',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'OPERATIONS DESK',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ValueListenableBuilder<String>(
            valueListenable: current,
            builder: (context, route, _) => Column(
              children: [
                for (final item in items)
                  _SidebarButton(
                    item: item,
                    selected: item.route == route,
                    onTap: () => onSelect(item.route),
                  ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'Stock control',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppColors.plumLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? Colors.white24 : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
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
