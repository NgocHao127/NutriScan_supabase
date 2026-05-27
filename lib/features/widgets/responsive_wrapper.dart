import 'package:flutter/material.dart';
import '../theme/app_responsive.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool useScroll;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.useScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: child,
      ),
    );

    if (useScroll) {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.hPad),
        child: content,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPad),
      child: content,
    );
  }
}
