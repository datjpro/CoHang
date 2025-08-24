import 'package:flutter/material.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showShadow;
  final double borderRadius;
  final Border? border;
  final bool isSelected;
  final Color? selectedColor;

  const ModernCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.showShadow = true,
    this.borderRadius = 16,
    this.border,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _isHovered = true);
                if (widget.onTap != null) {
                  _animationController.forward();
                }
              },
              onExit: (_) {
                setState(() => _isHovered = false);
                _animationController.reverse();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  color:
                      widget.gradient == null
                          ? (widget.isSelected
                              ? widget.selectedColor ??
                                  colorScheme.primaryContainer
                              : widget.backgroundColor ?? colorScheme.surface)
                          : null,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border:
                      widget.border ??
                      (widget.isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null),
                  boxShadow:
                      widget.showShadow
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                _isHovered ? 0.15 : 0.08,
                              ),
                              blurRadius: _isHovered ? 20 : 10,
                              offset: Offset(0, _isHovered ? 8 : 4),
                              spreadRadius: _isHovered ? 2 : 0,
                            ),
                          ]
                          : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    splashColor: colorScheme.primary.withOpacity(0.1),
                    highlightColor: colorScheme.primary.withOpacity(0.05),
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.all(24),
                      child: _buildContent(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (widget.title == null &&
        widget.leading == null &&
        widget.trailing == null) {
      return widget.child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 16),
              widget.trailing!,
            ],
          ],
        ),
        if (widget.title != null || widget.subtitle != null) ...[
          const SizedBox(height: 20),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.outline.withOpacity(0.3),
                  colorScheme.outline.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        widget.child,
      ],
    );
  }
}
