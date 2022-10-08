import 'package:doc_scanner/src/features/documents/domain/document_sort.dart';
import 'package:doc_scanner/src/features/documents/presentation/documents_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentsBar extends ConsumerWidget with PreferredSizeWidget {
  const DocumentsBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(documentsScreenSortProvider);
    return AppBar(
      title: Text(
        'My Documents',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        PopupMenuButton<DocumentSort>(
          initialValue: sort,
          onSelected: (sort) {
            ref.read(documentsScreenSortProvider.notifier).state = sort;
          },
          itemBuilder: (BuildContext context) => [
            for (final sort in DocumentSort.values)
              PopupMenuItem(
                value: sort,
                child: Text(sort.name),
              ),
          ],
          icon: Row(
            children: [
              Text(sort.name),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }
}
