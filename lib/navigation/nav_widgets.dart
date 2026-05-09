// Shared design tokens and primitive widgets for the two-tier navigation shell.
import 'package:flutter/material.dart';

// ── Colour palette ────────────────────────────────────────────────────────────

const kNavBg       = Color(0xFF0D1117);
const kNavSidebar  = Color(0xFF161B22);
const kNavHover    = Color(0xFF21262D);
const kNavActiveBg = Color(0xFF1C2E23);
const kNavAccent   = Color(0xFF00C896);
const kNavText     = Color(0xFFC9D1D9);
const kNavMuted    = Color(0xFF8B949E);
const kNavDivider  = Color(0xFF30363D);
const kSidebarW    = 220.0;

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
        style: const TextStyle(
          color: kNavMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Sidebar company / logo header ─────────────────────────────────────────────

class NavSidebarHeader extends StatelessWidget {
  final String name;
  const NavSidebarHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kNavAccent, Color(0xFF007A5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kNavText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: kNavAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Online',
                      style: TextStyle(color: kNavAccent, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
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
    final active      = widget.isActive;
    final textColor   = widget.textColor ?? (active ? kNavAccent : kNavText);
    final iconColor   = widget.iconColor ?? (active ? kNavAccent : kNavMuted);
    final bg          = active
        ? kNavActiveBg
        : (_hovered ? kNavHover : Colors.transparent);

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
                // Teal accent bar (active state only)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: active ? 3 : 0,
                  height: 16,
                  margin: EdgeInsets.only(right: active ? 8 : 0),
                  decoration: BoxDecoration(
                    color: kNavAccent,
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
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
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
              color: _hovered ? kNavHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.iconColor ?? kNavMuted,
            ),
          ),
        ),
      ),
    );
  }
}
