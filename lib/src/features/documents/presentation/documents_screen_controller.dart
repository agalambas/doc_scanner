import 'package:doc_scanner/src/features/documents/data/documents_repository.dart';
import 'package:doc_scanner/src/features/documents/domain/document.dart';
import 'package:doc_scanner/src/features/documents/domain/document_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'animated_grid_view.dart';

final documentIsDraggingProvider = StateProvider<bool>((ref) => false);
final documentCanBeDeletedProvider = StateProvider<bool>((ref) => false);

final documentsScreenSortProvider = StateProvider<DocumentSort>(
  (ref) => DocumentSort.date,
);

final documentsSortedStreamProvider = Provider<AsyncValue<List<Document>>>(
  (ref) {
    final sort = ref.watch(documentsScreenSortProvider);
    final documentsValue = ref.watch(documentsStreamProvider);
    return documentsValue.whenData((documents) {
      switch (sort) {
        case DocumentSort.date:
          return [...documents]..sort((a, b) => b.date.compareTo(a.date));
        case DocumentSort.name:
          return [...documents]..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    });
  },
);

final documentsScreenControllerProvider =
    ChangeNotifierProvider<DocumentsScreenController>(
  (ref) => DocumentsScreenController(
      documentsRepository: ref.watch(documentsRepositoryProvider)),
);

class DocumentsScreenController extends ChangeNotifier {
  DocumentsRepository documentsRepository;
  DocumentsScreenController({required this.documentsRepository});

  final gridKey = GlobalKey<AnimatedGridViewState>();

  Future<void> deleteDocument(Document document) =>
      documentsRepository.deleteDocument(document);
}
