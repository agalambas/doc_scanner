import 'package:flutter/material.dart';

import 'features/documents/presentation/documents_screen.dart';
import 'features/documents/presentation/pdf_screen.dart';
import 'features/scanner/presentation/scanner_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner',
      debugShowCheckedModeBanner: false,
      // debugShowMaterialGrid: true,
      theme: ThemeData(
        useMaterial3: true,
        // brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const DocumentsScreen(),
        '/scanner': (_) => const ScannerScreen(),
        '/pdf': (context) {
          final path = ModalRoute.of(context)!.settings.arguments as String;
          return PdfScreen(path);
        },
      },
    );
  }
}
