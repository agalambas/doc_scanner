import 'package:doc_scanner/src/features/documents/data/documents_repository.dart';
import 'package:doc_scanner/src/features/scanner/domain/document_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

final saveDocumentControllerProvider =
    StateNotifierProvider.autoDispose<SaveDocumentController, AsyncValue>(
  (ref) => SaveDocumentController(
    documentsRepository: ref.watch(documentsRepositoryProvider),
  ),
);

class SaveDocumentController extends StateNotifier<AsyncValue> {
  final DocumentsRepository documentsRepository;
  SaveDocumentController({
    required this.documentsRepository,
  }) : super(const AsyncValue.data(null));

  final nameController = TextEditingController();
  String get name => nameController.text;

  Future<Uint8List> rotatedPageBytes(DocumentPage page) async {
    var bytes = await page.file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final rotatedImage = img.copyRotate(image, page.turns * 90);
    final rotatedImageBytes = img.encodeJpg(rotatedImage);
    return Uint8List.fromList(rotatedImageBytes);
  }

  Future<bool> save(List<DocumentPage> pages) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pdf = pw.Document();
      for (final page in pages) {
        final bytes = await rotatedPageBytes(page);
        final pdfPage = pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(bytes),
              ),
            );
          },
        );
        pdf.addPage(pdfPage);
      }
      final bytes = await pdf.save();
      await documentsRepository.addDocument(
        name.isEmpty ? 'doc_${DateTime.now().millisecondsSinceEpoch}' : name,
        bytes,
      );
    });
    return !state.hasError;
  }
}
