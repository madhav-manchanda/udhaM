import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'udham_colors.dart';

export 'udham_colors.dart';

/// Shared design tokens and atomic widgets for the Industrial Precision design system.

// ---------------------------------------------------------------------------
// Money display
// ---------------------------------------------------------------------------

/// Space Mono text for monetary amounts — tabular, always.
class MoneyDisplay extends StatelessWidget {
  const MoneyDisplay({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.color,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? UdhamColors.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Technical label (Space Mono small caps)
// ---------------------------------------------------------------------------

class TechLabel extends StatelessWidget {
  const TechLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 10,
        color: color ?? UdhamColors.onSurfaceVariant,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status pill / chip
// ---------------------------------------------------------------------------

class UdhamChip extends StatelessWidget {
  const UdhamChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08,
          color: textColor ?? color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Participant avatar
// ---------------------------------------------------------------------------

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({super.key, required this.name, this.radius = 18});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: UdhamColors.primaryContainer,
      foregroundColor: UdhamColors.onPrimaryContainer,
      child: Text(
        _initials(name),
        style: GoogleFonts.spaceMono(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
          color: UdhamColors.onPrimaryContainer,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Section divider with label
// ---------------------------------------------------------------------------

class LedgerDateHeader extends StatelessWidget {
  const LedgerDateHeader({super.key, required this.label, this.amount});

  final String label;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
      child: Row(
        children: [
          TechLabel(label, color: UdhamColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 0.5, color: UdhamColors.outlineVariant),
          ),
          if (amount != null) ...[
            const SizedBox(width: 8),
            TechLabel(amount!, color: UdhamColors.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mechanical action button (orange with shadow offset)
// ---------------------------------------------------------------------------

class MechButton extends StatefulWidget {
  const MechButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.filled = true,
    this.small = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;
  final bool small;

  @override
  State<MechButton> createState() => _MechButtonState();
}

class _MechButtonState extends State<MechButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled
        ? UdhamColors.secondaryContainer
        : UdhamColors.surfaceContainerHigh;
    final fg = widget.filled
        ? UdhamColors.onSecondaryContainer
        : UdhamColors.onSurface;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _pressed ? 1 : 0,
          _pressed ? 1 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: UdhamColors.primary.withValues(alpha: 0.6),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.small ? 8 : 10,
          vertical: widget.small ? 6 : 9,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.small ? 14 : 16, color: fg),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: widget.small ? 11 : 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: UdhamColors.outline),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: UdhamColors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loader
// ---------------------------------------------------------------------------

class SkeletonBox extends StatefulWidget {
  const SkeletonBox(
      {super.key, required this.width, required this.height, this.radius = 2});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerHigh
              .withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers shared across screens
// ---------------------------------------------------------------------------

void showError(BuildContext context, Object error) {
  final text = error.toString();
  final message =
      text.contains(': ') ? text.substring(text.indexOf(': ') + 2) : text;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UdhamColors.errorContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: UdhamColors.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

String describe(Object error) {
  final text = error.toString();
  if (text.contains(': ')) return text.substring(text.indexOf(': ') + 2);
  return text;
}

// Legacy compat shim — keep old names working
class StatusChip extends UdhamChip {
  const StatusChip({super.key, required super.label, required super.color});
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Expanded(
              child: TechLabel(title, color: UdhamColors.onSurfaceVariant)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.minor,
    required this.currency,
    this.signed = false,
    this.style,
  });

  final int minor;
  final String currency;
  final bool signed;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(_format(), style: style);
  }

  String _format() {
    final sym = _sym();
    final val = _val();
    if (signed && minor > 0) return '+$sym$val';
    return '$sym$val';
  }

  String _sym() {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '${currency.toUpperCase()} ';
    }
  }

  String _val() {
    final major = minor.abs() ~/ 100;
    final cents = minor.abs() % 100;
    final sign = minor < 0 ? '-' : '';
    return '$sign$major.${cents.toString().padLeft(2, '0')}';
  }
}
