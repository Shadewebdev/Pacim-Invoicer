import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/document_type.dart';
import '../theme/app_color_tokens.dart';

class _Destination {
  const _Destination({
    required this.label,
    required this.location,
    required this.icon,
  });

  final String label;
  final String location;
  final IconData icon;
}

final List<_Destination> _documentDestinations = [
  for (final type in DocumentType.values)
    _Destination(
      label: type.pluralDisplayName,
      location: '/${type.routeSegment}',
      icon: switch (type) {
        DocumentType.quotation => Icons.request_quote_outlined,
        DocumentType.salesOrder => Icons.shopping_cart_outlined,
        DocumentType.deliveryOrder => Icons.local_shipping_outlined,
      },
    ),
];

const _settingsDestination = _Destination(
  label: 'Settings',
  location: '/settings',
  icon: Icons.settings_outlined,
);

/// Navigation between document lists and settings. Full width shows labels;
/// [isRail] shows icons only.
class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({
    required this.isRail,
    this.onDestinationSelected,
    super.key,
  });

  static const double fullWidth = 220;
  static const double railWidth = 56;

  final bool isRail;

  /// Called after navigating, so a drawer can close itself.
  final VoidCallback? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final currentPath = GoRouterState.of(context).uri.path;
    Widget item(_Destination destination) => _SidebarItem(
      destination: destination,
      isRail: isRail,
      isSelected: currentPath == destination.location,
      onTap: () {
        context.go(destination.location);
        onDestinationSelected?.call();
      },
    );
    return Container(
      width: isRail ? railWidth : fullWidth,
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(right: BorderSide(color: tokens.rule)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final destination in _documentDestinations) item(destination),
          const Spacer(),
          item(_settingsDestination),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.isRail,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool isRail;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final color = isSelected ? tokens.action : tokens.ink;
    final icon = Icon(destination.icon, size: 18, color: color);
    final content = isRail
        ? Center(child: icon)
        : Row(
            children: [
              const SizedBox(width: 16),
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
    final row = InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        color: isSelected ? tokens.action.withValues(alpha: 0.1) : null,
        child: content,
      ),
    );
    return isRail ? Tooltip(message: destination.label, child: row) : row;
  }
}
