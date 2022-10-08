import 'package:doc_scanner/src/features/scanner/domain/document_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_document_controller.dart';

/// Generic function to show a platform-aware Material or Cupertino dialog
Future<bool?> showSaveDocumentDialog(
  BuildContext context,
  List<DocumentPage> pages,
) =>
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(builder: (context, ref, _) {
        final state = ref.watch(saveDocumentControllerProvider);
        final controller = ref.read(saveDocumentControllerProvider.notifier);
        return AlertDialog(
          title: const Text('Document name'),
          content: TextField(
            controller: controller.nameController,
          ),
          actions: [
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final success = await controller.save(pages);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(success);
                    },
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        );
      }),
    );
