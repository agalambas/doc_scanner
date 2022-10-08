import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedGridView extends StatefulWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int childCount;
  final IndexedWidgetBuilder builder;

  const AnimatedGridView({
    Key? key,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.childCount,
    required this.builder,
  }) : super(key: key);

  @override
  State<AnimatedGridView> createState() => AnimatedGridViewState();
}

class AnimatedGridViewState extends State<AnimatedGridView> {
  int? _deletedChildIndex;
  late Completer deletionCompleter;

  Future<void> delete(int i) async {
    setState(() => _deletedChildIndex = i);
    deletionCompleter = Completer();
    await deletionCompleter.future;
  }

  Future<void> _onDeleted() async {
    _deletedChildIndex = null;
    deletionCompleter.complete();
  }

  Offset _translationOffset(int i) => i % widget.crossAxisCount == 0
      ? const Offset(2, -1)
      : const Offset(-1, 0);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.childCount,
      itemBuilder: (context, i) {
        final child = widget.builder(context, i);
        if (_deletedChildIndex != null) {
          if (i == _deletedChildIndex) {
            return child
                .animate(onComplete: (_) => _onDeleted())
                .visibility(duration: 100.ms)
                //! workarround to avoid setState before the animation ends
                .then(delay: 1.ms);
          }
          if (i > _deletedChildIndex!) {
            return child.animate().slide(
                  begin: Offset.zero,
                  duration: 100.ms,
                  end: _translationOffset(i),
                );
          }
        }
        return child;
      },
    );
  }
}
