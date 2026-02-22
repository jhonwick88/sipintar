import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'surat_form_page.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Surat')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null && code.contains('form?id=')) {
              // Parse basic info from URL for demo
              final uri = Uri.parse(code.replaceFirst('#/', ''));
              final id = uri.queryParameters['id'] ?? '';
              final kode = uri.queryParameters['kode'] ?? '';

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SuratFormPage(
                    templateId: id,
                    namaSurat: "Surat dari Scan",
                    kodeSurat: kode,
                  ),
                ),
              );
              break;
            }
          }
        },
      ),
    );
  }
}
