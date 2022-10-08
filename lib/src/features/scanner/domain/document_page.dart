import 'dart:io';

class DocumentPage {
  final File file;

  /// roration in degrees
  final int turns;

  DocumentPage(this.file, {this.turns = 0});
}
