import 'package:doc_scanner/src/utils/name_from_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfScreen extends StatelessWidget {
  final String path;
  const PdfScreen(this.path, {Key? key}) : super(key: key);

  String get name => nameFromPath(path).split('.').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SafeArea(
        child: PDFView(
          filePath: path,
          autoSpacing: false,
          pageFling: false,
          pageSnap: false,
        ),
      ),
    );
  }
}
