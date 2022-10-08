import 'dart:io';

import 'package:doc_scanner/src/features/documents/domain/document.dart';
import 'package:doc_scanner/src/utils/in_memory_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:watcher/watcher.dart'; //!

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepository(),
);

class DocumentsRepository {
  final _documents = InMemoryStore<List<Document>>();

  Stream<List<Document>> watchDocuments() async* {
    // read documents from storage
    final directory = await getApplicationDocumentsDirectory();
    final systemFiles = directory.listSync();
    // add documents to memory store
    _documents.value = systemFiles
        .where((systemFile) => systemFile.path.endsWith('.pdf'))
        .map((systemFile) {
      final file = File(systemFile.path);
      return Document.fromFile(file);
    }).toList();
    // watch memory store
    yield* _documents.stream;
  }

  Future<void> addDocument(String name, Uint8List bytes) async {
    // add document to storage
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/$name.pdf");
    await file.writeAsBytes(bytes);
    // add document to memory store
    _documents.value = [
      Document.fromFile(file),
      ..._documents.value,
    ];
  }

  Future<void> deleteDocument(Document document) async {
    // delete document from memory store
    _documents.value = [..._documents.value..remove(document)];
    // delete document from storage
    await File(document.path).delete();
  }
}

final documentsStreamProvider = StreamProvider<List<Document>>(
  (ref) => ref.watch(documentsRepositoryProvider).watchDocuments(),
);
