import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logo extends ConsumerWidget {
  final double? height;
  const Logo({super.key, this.height = 250});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FittedBox(
        child: Image.asset(
      'assets/images/logo.png',
      height: height,
    ));
  }
}
