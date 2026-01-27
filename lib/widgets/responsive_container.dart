import 'package:flutter/material.dart';

/// A responsive container that constrains max width for web/desktop viewing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? maxWidth : double.infinity,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
