import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const CustomBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// A custom bottom navigation bar widget for food delivery app
/// Implements thumb-accessible navigation with smooth transitions
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.showLabels = true,
  });

  /// Navigation items based on Mobile Navigation Hierarchy
  static const List<CustomBottomBarItem> navigationItems = [
    CustomBottomBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home-dashboard',
    ),
    CustomBottomBarItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Cart',
      route: '/shopping-cart',
    ),
    CustomBottomBarItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Orders',
      route: '/order-history',
    ),
    CustomBottomBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile-dashboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navigationItems.length,
              (index) =>
                  _buildNavigationItem(context, navigationItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    final effectiveSelectedColor = selectedItemColor ?? colorScheme.primary;
    final effectiveUnselectedColor =
        unselectedItemColor ?? colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          }
          // Navigate to the route
          Navigator.pushReplacementNamed(context, item.route);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with scale animation
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  color: isSelected
                      ? effectiveSelectedColor
                      : effectiveUnselectedColor,
                  size: 24,
                ),
              ),
              if (showLabels) ...[
                const SizedBox(height: 4),
                // Label with fade animation
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected
                        ? effectiveSelectedColor
                        : effectiveUnselectedColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant of CustomBottomBar with floating cart summary
class CustomBottomBarWithCart extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;
  final String cartTotal;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;

  const CustomBottomBarWithCart({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onCartTap,
    this.cartItemCount = 0,
    this.cartTotal = '₹0.00',
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating cart summary (shown when cart has items)
        if (cartItemCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.primary,
              child: InkWell(
                onTap:
                    onCartTap ??
                    () {
                      Navigator.pushNamed(context, '/shopping-cart');
                    },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Cart icon with badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                          if (cartItemCount > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  cartItemCount > 99
                                      ? '99+'
                                      : cartItemCount.toString(),
                                  style: theme.textTheme.labelSmall!.copyWith(
                                    color: colorScheme.onError,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Cart info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$cartItemCount ${cartItemCount == 1 ? 'item' : 'items'}',
                              style: theme.textTheme.labelMedium!.copyWith(
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            Text(
                              cartTotal,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.onPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Bottom navigation bar
        CustomBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          elevation: elevation,
        ),
      ],
    );
  }
}
