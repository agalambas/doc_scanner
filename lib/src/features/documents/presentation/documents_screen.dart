import 'package:doc_scanner/src/common_widgets/async_value_widget.dart';
import 'package:doc_scanner/src/features/documents/domain/document.dart';
import 'package:doc_scanner/src/features/documents/presentation/animated_grid_view.dart';
import 'package:doc_scanner/src/features/documents/presentation/document_trash_fab.dart';
import 'package:doc_scanner/src/features/documents/presentation/documents_bar.dart';
import 'package:doc_scanner/src/features/documents/presentation/documents_screen_controller.dart';
import 'package:doc_scanner/src/features/scanner/presentation/scanner_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'document_card.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  void dragStarted(WidgetRef ref) {
    HapticFeedback.vibrate();
    ref.read(documentIsDraggingProvider.notifier).state = true;
  }

  void dragEnd(WidgetRef ref) {
    ref.read(documentIsDraggingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsValue = ref.watch(documentsSortedStreamProvider);
    final controller = ref.watch(documentsScreenControllerProvider);
    final isDragging = ref.watch(documentIsDraggingProvider);
    return Scaffold(
      appBar: const DocumentsBar(),
      body: AsyncValueWidget(
        value: documentsValue,
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(
              child: Text('Scan your first document!'),
            );
          }
          return AnimatedGridView(
            key: controller.gridKey,
            crossAxisCount: 3,
            childAspectRatio: 3 / 4,
            childCount: documents.length,
            builder: (context, i) {
              final document = documents[i];
              final child = DocumentCard(
                document,
                onPressed: () => Navigator.of(context).pushNamed(
                  '/pdf',
                  arguments: document.path,
                ),
              );
              return LongPressDraggable<Document>(
                data: document,
                maxSimultaneousDrags: isDragging ? 0 : 1,
                onDragStarted: () => dragStarted(ref),
                onDragEnd: (_) => dragEnd(ref),
                feedback: Consumer(
                  builder: (context, ref, _) {
                    final canBeDeleted =
                        ref.watch(documentCanBeDeletedProvider);
                    return SizedBox(
                      width: 96,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Material(
                          // default card m3 shape
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              canBeDeleted
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Colors.transparent,
                              BlendMode.multiply,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                childWhenDragging: const SizedBox.shrink(),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isDragging
          ? const DocumentTrashFAB()
          : FloatingActionButton(
              onPressed: () async {
                final success =
                    await ref.read(scannerScreenControllerProvider).scan();
                // ignore: use_build_context_synchronously
                if (success) Navigator.of(context).pushNamed('/scanner');
              },
              child: const Icon(Icons.document_scanner),
            ),
    );
  }
}
