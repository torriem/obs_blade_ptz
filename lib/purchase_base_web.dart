import 'package:flutter/material.dart';

/// Web version of PurchaseBase that doesn't use in-app purchases
/// since they're not supported on web platforms
class PurchaseBase extends StatelessWidget {
  final Widget child;

  const PurchaseBase({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
