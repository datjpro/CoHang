import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;

    if (screenWidth >= tabletBreakpoint && desktop != null) {
      return desktop!;
    } else if (screenWidth >= mobileBreakpoint && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    DeviceType deviceType;

    if (context.isDesktop) {
      deviceType = DeviceType.desktop;
    } else if (context.isTablet) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.mobile;
    }

    return builder(context, deviceType);
  }
}

enum DeviceType { mobile, tablet, desktop }

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final EdgeInsets padding;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        int columns = switch (deviceType) {
          DeviceType.mobile => mobileColumns,
          DeviceType.tablet => tabletColumns,
          DeviceType.desktop => desktopColumns,
        };

        return Padding(
          padding: padding,
          child: GridView.count(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio ?? 1.0,
            children: children,
          ),
        );
      },
    );
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  T getValue(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => desktop ?? tablet ?? mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.mobile => mobile,
    };
  }
}

class ResponsiveWidget extends StatelessWidget {
  final ResponsiveValue<Widget> child;

  const ResponsiveWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return child.getValue(deviceType);
      },
    );
  }
}

extension ResponsiveExtensions on BuildContext {
  T responsiveValue<T>(ResponsiveValue<T> value) {
    DeviceType deviceType;

    if (isDesktop) {
      deviceType = DeviceType.desktop;
    } else if (isTablet) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.mobile;
    }

    return value.getValue(deviceType);
  }
}
