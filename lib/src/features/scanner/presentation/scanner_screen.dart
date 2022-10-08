import 'package:doc_scanner/src/features/scanner/presentation/save_document_dialog.dart';
import 'package:doc_scanner/src/features/scanner/presentation/scanner_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page_trailing.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(scannerScreenControllerProvider);
    return WillPopScope(
      onWillPop: () async {
        controller.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Document'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () async {
                  final success =
                      await showSaveDocumentDialog(context, controller.pages);
                  if (success == true) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    controller.clear();
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
        body: PageView(
          controller: controller.pageController,
          children: [
            for (final page in controller.pages)
              Center(
                child: RotatedBox(
                  quarterTurns: page.turns,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(16),
                    child: Image.file(page.file),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: controller.scan,
                child: const Icon(Icons.add_a_photo, size: 32),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: kBottomNavigationBarHeight * 1.5,
          child: animatedPageTrailing(
            currentPage: controller.currentPage,
            lastPage: controller.lastPage,
            pageCount: controller.pages.length,
          ),
        ),
      ),
    );
  }

  Widget? animatedPageTrailing({
    required int currentPage,
    required int lastPage,
    required int pageCount,
  }) {
    final trailing = PageTrailing(label: '$currentPage / $pageCount');
    if (currentPage == pageCount + 1) {
      return trailing.animate().fadeOut(duration: 200.ms).slide(
            duration: 500.ms,
            begin: Offset.zero,
            end: const Offset(0, 1),
          );
    } else if (currentPage == pageCount && lastPage == pageCount + 1) {
      return trailing
          .animate()
          .slide(
            duration: 250.ms,
            begin: const Offset(0, 1),
            end: Offset.zero,
          )
          .fadeIn(delay: 150.ms, duration: 100.ms);
    }
    return trailing;
  }
}
