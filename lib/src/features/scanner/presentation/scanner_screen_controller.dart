import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner/src/features/documents/data/documents_repository.dart';
import 'package:doc_scanner/src/features/scanner/domain/document_page.dart';
import 'package:doc_scanner/src/utils/name_from_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

final scannerScreenControllerProvider =
    ChangeNotifierProvider<ScannerScreenController>(
  (ref) => ScannerScreenController(
    documentsRepository: ref.watch(documentsRepositoryProvider),
  ),
);

class ScannerScreenController extends ChangeNotifier {
  DocumentsRepository documentsRepository;
  ScannerScreenController({required this.documentsRepository}) {
    createPageListener();
  }

  final pageController = PageController();
  List<DocumentPage> pages = [];
  int currentPage = 0;
  late int lastPage = currentPage;

  void createPageListener() {
    pageController.addListener(() {
      if (!pageController.hasClients) return;
      final nextPage = (pageController.page! + 1).round();
      if (currentPage != nextPage) {
        lastPage = currentPage;
        currentPage = nextPage;
        notifyListeners();
      }
    });
  }

  Future<bool> scan() async {
    final paths = await CunningDocumentScanner.getPictures();
    if (paths == null || paths.isEmpty) return false;
    final directory = await getTemporaryDirectory();
    final newPages = await Future.wait(paths.map((path) async {
      final bytes = await File(path).readAsBytes();
      final name = nameFromPath(path);
      final file = File('${directory.path}/$name');
      file.writeAsBytes(bytes);
      return DocumentPage(file);
    }));
    pages.addAll(newPages);
    currentPage = 1;
    notifyListeners();
    return true;
  }

  void deletePage() async {
    pages.removeAt(currentPage - 1);
    notifyListeners();
  }

  Future<void> rotatePage() async {
    final currentIndex = currentPage - 1;
    final page = pages[currentIndex];
    pages[currentIndex] = DocumentPage(page.file, turns: page.turns + 1);
    notifyListeners();
  }

  Future<Uint8List> rotatedPageBytes(DocumentPage page) async {
    var bytes = await page.file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final rotatedImage = img.copyRotate(image, page.turns * 90);
    final rotatedImageBytes = img.encodeJpg(rotatedImage);
    return Uint8List.fromList(rotatedImageBytes);
  }

  Future<bool> save() async {
    try {
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
        'doc_${DateTime.now().millisecondsSinceEpoch}',
        bytes,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void clear() {
    pages.clear();
    currentPage = 0;
    lastPage = 0;
  }
}
