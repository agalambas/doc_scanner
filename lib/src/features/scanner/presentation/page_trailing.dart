import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scanner_screen_controller.dart';

class PageTrailing extends ConsumerWidget {
  final String label;
  const PageTrailing({Key? key, required this.label}) : super(key: key);

  void rotate(WidgetRef ref) {
    ref.read(scannerScreenControllerProvider).rotatePage();
  }

  void delete(WidgetRef ref) {
    ref.read(scannerScreenControllerProvider).deletePage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).errorColor,
          ),
          onPressed: () => delete(ref),
          child: const Icon(Icons.delete),
        ),
        Text(label),
        OutlinedButton(
          onPressed: () => rotate(ref),
          child: const Icon(Icons.rotate_90_degrees_cw),
        ),
      ],
    );
  }
}
