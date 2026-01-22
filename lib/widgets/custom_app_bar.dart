import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types
enum CustomAppBarVariant {
  /// Standard app bar with title and actions
  standard,

  /// Search-focused app bar with search field
  search,

  /// Restaurant detail app bar with back button and actions
  detail,

  /// Transparent app bar for overlaying content
  transparent,
}

/// A custom app bar widget for food delivery app
/// Implements clean, content-driven interfaces with contextual actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarVariant variant;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchTap;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final Function(String)? onSearchSubmitted;
  final String? searchHint;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    super.key,
    this.variant = CustomAppBarVariant.standard,
    this.title,
    this.titleWidget,
    this.actions,
    this.onBackPressed,
    this.onSearchTap,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.searchHint = 'Search restaurants, dishes...',
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.systemOverlayStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.detail:
        return _buildDetailAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.transparent:
        return _buildTransparentAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.standard:
        return _buildStandardAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      systemOverlayStyle: systemOverlayStyle,
      leading: automaticallyImplyLeading && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              tooltip: 'Back',
            )
          : null,
      actions: actions,
    );
  }

  Widget _buildSearchAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      systemOverlayStyle: systemOverlayStyle,
      automaticallyImplyLeading: false,
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          onSubmitted: onSearchSubmitted,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: searchHint,
            hintStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: searchController?.text.isNotEmpty ?? false
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      searchController?.clear();
                      if (onSearchChanged != null) {
                        onSearchChanged!('');
                      }
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDetailAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      systemOverlayStyle: systemOverlayStyle,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: colorScheme.onSurface,
          ),
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
      ),
      actions: actions?.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: action,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransparentAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.light,
      leading: automaticallyImplyLeading && Navigator.canPop(context)
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              tooltip: 'Back',
            )
          : null,
      actions: actions?.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: action,
          ),
        );
      }).toList(),
    );
  }
}

/// A sticky header app bar for restaurant details with category navigation
class CustomStickyAppBar extends StatelessWidget {
  final String title;
  final List<String> categories;
  final int selectedCategoryIndex;
  final Function(int) onCategorySelected;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomStickyAppBar({
    super.key,
    required this.title,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App bar section
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actions != null) ...actions!,
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Category tabs section
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = selectedCategoryIndex == index;
                  return InkWell(
                    onTap: () => onCategorySelected(index),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
