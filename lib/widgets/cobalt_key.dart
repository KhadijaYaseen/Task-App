import 'package:flutter/material.dart';
import '../theme/cobalt_theme.dart';

enum CobaltKeyVariant { primary, neutral, outline }

/// Tactile 3D Keycap button inspired directly by Hallmark Cobalt (.key, .key--primary)
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
    this.variant = CobaltKeyVariant.primary,
    this.isSmall = false,
  });

  @override
  State<CobaltKey> createState() => _CobaltKeyState();
}

class _CobaltKeyState extends State<CobaltKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color edge;
    Border? border;

    switch (widget.variant) {
      case CobaltKeyVariant.primary:
        bg = CobaltTheme.accent;
        fg = Colors.white;
        edge = CobaltTheme.accentEdge;
        border = Border.all(color: CobaltTheme.accentHover, width: 1);
        break;
      case CobaltKeyVariant.neutral:
        bg = CobaltTheme.keyFace;
        fg = CobaltTheme.ink;
        edge = CobaltTheme.keyEdge;
        border = Border.all(color: CobaltTheme.rule2, width: 1);
        break;
      case CobaltKeyVariant.outline:
        bg = Colors.transparent;
        fg = CobaltTheme.ink;
        edge = Colors.transparent;
        border = Border.all(color: CobaltTheme.rule2, width: 1);
        break;
    }

    final double lift = _isPressed ? 1.0 : 3.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: _isPressed ? 2.0 : 0.0, bottom: _isPressed ? 0.0 : 2.0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 12 : 18,
          vertical: widget.isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(CobaltTheme.radiusInput),
          border: border,
          boxShadow: widget.variant == CobaltKeyVariant.outline
              ? null
              : [
                  BoxShadow(
                    color: edge,
                    offset: Offset(0, lift),
                    blurRadius: 0,
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
            Text(
              widget.label,
              style: TextStyle(
                color: fg,
                fontSize: widget.isSmall ? 12 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
