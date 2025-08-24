import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    
    Widget button = switch (variant) {
      ButtonVariant.primary => _buildElevatedButton(context, colorScheme),
      ButtonVariant.secondary => _buildOutlinedButton(context, colorScheme),
      ButtonVariant.ghost => _buildTextButton(context, colorScheme),
      ButtonVariant.danger => _buildElevatedButton(
          context, 
          colorScheme,
          customBackgroundColor: colorScheme.error,
          customForegroundColor: colorScheme.onError,
        ),
    };

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildElevatedButton(
    BuildContext context,
    ColorScheme colorScheme, {
    Color? customBackgroundColor,
    Color? customForegroundColor,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? customBackgroundColor ?? colorScheme.primary,
        foregroundColor: foregroundColor ?? customForegroundColor ?? colorScheme.onPrimary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        disabledBackgroundColor: colorScheme.surfaceVariant,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, ColorScheme colorScheme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? colorScheme.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: backgroundColor ?? colorScheme.primary,
          width: 1.5,
        ),
        disabledForegroundColor: colorScheme.onSurfaceVariant,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context, ColorScheme colorScheme) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? colorScheme.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledForegroundColor: colorScheme.onSurfaceVariant,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? context.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('Đang xử lý...'),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      ButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    };
  }

  double _getIconSize() {
    return switch (size) {
      ButtonSize.small => 16,
      ButtonSize.medium => 18,
      ButtonSize.large => 20,
    };
  }
}

enum ButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}
