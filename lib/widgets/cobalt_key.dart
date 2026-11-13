import 'package:flutter/material.dart';
import '../theme/cobalt_theme.dart';

enum CobaltKeyVariant { primary, neutral, outline, gradient }

/// Elevated tactile button widget.
class CobaltKey extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final CobaltKeyVariant variant;
  final bool isSmall;

  const CobaltKey({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CobaltKeyVariant.gradient,
    this.isSmall = false,
  });

  @override
  State<CobaltKey> createState() => _CobaltKeyState();
}

class _CobaltKeyState extends State<CobaltKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color fg;
    Color edge;
    Border? border;
    bool isGradient = widget.variant == CobaltKeyVariant.gradient;

    switch (widget.variant) {
      case CobaltKeyVariant.primary:
        fg = Colors.white;
        edge = CobaltTheme.purpleDark;
        border = Border.all(color: CobaltTheme.purplePrimary, width: 1);
        break;
      case CobaltKeyVariant.gradient:
        fg = Colors.white;
        edge = CobaltTheme.purpleDark;
        border = null;
        break;
      case CobaltKeyVariant.neutral:
        fg = CobaltTheme.ink;
        edge = CobaltTheme.keyEdge;
        border = Border.all(color: CobaltTheme.rule2, width: 1);
        break;
      case CobaltKeyVariant.outline:
        fg = CobaltTheme.ink;
        edge = Colors.transparent;
        border = Border.all(color: CobaltTheme.rule2, width: 1);
        break;
    }

    final double lift = _isPressed ? 1.0 : 3.0;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _isPressed ? 2.0 : 0.0,
          bottom: _isPressed ? 0.0 : 2.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 12 : 18,
          vertical: widget.isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isGradient || widget.variant == CobaltKeyVariant.primary
              ? LinearGradient(
                  colors: _isPressed
                      ? [const Color(0xFF6D28D9), const Color(0xFF4338CA)]
                      : [CobaltTheme.purplePrimary, const Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: (isGradient || widget.variant == CobaltKeyVariant.primary)
              ? null
              : (widget.variant == CobaltKeyVariant.neutral
                  ? CobaltTheme.keyFace
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
          border: border,
          boxShadow: widget.variant == CobaltKeyVariant.outline
              ? null
              : [
                  BoxShadow(
                    color: edge.withAlpha(180),
                    offset: Offset(0, lift),
                    blurRadius: 0,
                  ),
                  if (isGradient || widget.variant == CobaltKeyVariant.primary)
                    BoxShadow(
                      color: CobaltTheme.purplePrimary.withAlpha(70),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.isSmall ? 15 : 18, color: fg),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: fg,
                  fontSize: widget.isSmall ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
