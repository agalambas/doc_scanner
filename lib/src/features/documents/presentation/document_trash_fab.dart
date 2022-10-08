import 'package:doc_scanner/src/features/documents/domain/document.dart';
import 'package:doc_scanner/src/features/documents/presentation/documents_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentTrashFAB extends ConsumerWidget {
  const DocumentTrashFAB({Key? key}) : super(key: key);

  bool turnDeletable(WidgetRef ref) {
    HapticFeedback.vibrate();
    ref.read(documentCanBeDeletedProvider.notifier).state = true;
    return true;
  }

  void turnNotDeletable(WidgetRef ref) {
    ref.read(documentCanBeDeletedProvider.notifier).state = false;
  }

  void delete(WidgetRef ref, Document document) async {
    turnNotDeletable(ref);
    final documents = ref.read(documentsSortedStreamProvider).value!;
    final position = documents.indexOf(document);
    final controller = ref.read(documentsScreenControllerProvider);
    await controller.gridKey.currentState?.delete(position);
    await controller.deleteDocument(document);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Document>(
      onWillAccept: (_) => turnDeletable(ref),
      onLeave: (_) => turnNotDeletable(ref),
      onAccept: (document) => delete(ref, document),
      builder: (context, _, __) => FloatingActionButton(
        onPressed: null,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete),
      ),
    );
  }
}
