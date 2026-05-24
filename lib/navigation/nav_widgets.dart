// Shared design tokens and primitive widgets for the two-tier navigation shell.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/company/company_provider.dart';

// ── Layout constant (non-colour — safe to keep const) ─────────────────────────
const kSidebarW = 220.0;

// ── Theme helpers (replaces the old hardcoded kNav* constants) ────────────────
// Each widget now reads from Theme.of(context) so all custom themes apply.

extension NavTheme on BuildContext {
  ColorScheme get _cs => Theme.of(this).colorScheme;

  Color get navSidebarBg     => _cs.surfaceContainer;
  Color get navHover         => _cs.surfaceContainerHigh;
  Color get navActiveBg      => _cs.primaryContainer;
  Color get navAccent        => _cs.primary;
  Color get navText          => _cs.onSurface;
  Color get navMuted         => _cs.onSurfaceVariant;
  Color get navDivider       => _cs.outline.withValues(alpha: 0.3);
  Color get navScaffoldBg    => Theme.of(this).scaffoldBackgroundColor;
}

// ── Section label ─────────────────────────────────────────────────────────────

class NavSectionLabel extends StatelessWidget {
  final String text;
  const NavSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          color: context.navMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Sidebar company / logo header ─────────────────────────────────────────────

class NavSidebarHeader extends ConsumerWidget {
  final String name;
  final VoidCallback? onHideSidebar;

  const NavSidebarHeader({super.key, required this.name, this.onHideSidebar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(selectedCompanyProvider);
    final accent  = context.navAccent;

    ImageProvider? logoProvider;
    if (company?.logo != null && company!.logo!.isNotEmpty) {
      try {
        logoProvider = MemoryImage(base64Decode(company.logo!));
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
              image: logoProvider != null
                  ? DecorationImage(image: logoProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: logoProvider == null
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.navText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onHideSidebar != null)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.menu_open, color: context.navMuted),
              tooltip: "Hide Sidebar",
              onPressed: onHideSidebar,
            ),
        ],
      ),
    );
  }
}

// ── Nav item (hover + optional active state) ──────────────────────────────────

class NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? textColor;
  final Color? iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.textColor,
    this.iconColor,
    this.isActive = false,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active    = widget.isActive;
    final accent    = context.navAccent;
    final textColor = widget.textColor ?? (active ? accent : context.navText);
    final iconColor = widget.iconColor ?? (active ? accent : context.navMuted);
    final bg        = active
        ? context.navActiveBg
        : (_hovered ? context.navHover : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width:  active ? 3 : 0,
                  height: 16,
                  margin: EdgeInsets.only(right: active ? 8 : 0),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(widget.icon, size: 18, color: iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small icon button for the hardware bar ────────────────────────────────────

class NavIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  const NavIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<NavIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _hovered ? context.navHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.iconColor ?? context.navMuted,
            ),
          ),
        ),
      ),
    );
  }
}
