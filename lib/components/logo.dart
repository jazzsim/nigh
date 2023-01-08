import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../appsetting.dart';
import '../constant.dart';

class Logo extends ConsumerWidget {
  final double? height;
  const Logo({super.key, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
         Icon(
          Icons.nightlight,
          color: themePrimary,
          size: height ?? 90,
        ),
        Text(
          'Nigh',
          style: ref.watch(textThemeProvider(context)).titleLarge?.copyWith(color: themePrimary),
        ),
      ],
    );
  }
}
