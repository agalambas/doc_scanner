import 'dart:io';

import 'package:doc_scanner/src/utils/name_from_path.dart';

class Document {
  final String path;
  final DateTime date;

  Document({required this.path, required this.date});

  factory Document.fromFile(File file) {
    final date = file.lastModifiedSync();
    return Document(path: file.path, date: date);
  }

  String get fullName => nameFromPath(path);
  String get name => fullName.split('.').first;
}
