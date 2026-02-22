import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../template/presentation/template_provider.dart';
import '../../template/domain/template_entity.dart';
import 'surat_form_page.dart';
import 'scanner_page.dart';


class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(activeTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Surat Desa'),
        centerTitle: true,
      ),
      floatingActionButton: Theme.of(context).platform == TargetPlatform.android || 
                             Theme.of(context).platform == TargetPlatform.iOS
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScannerPage()),
              ),
              label: const Text('Scan QR'),
              icon: const Icon(Icons.qr_code_scanner),
            )
          : null,
      body: templatesAsync.when(

        data: (templates) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 3/2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return Card(
              child: InkWell(
                onTap: () => _showQRCode(context, template),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      template.namaSurat,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(template.kodeSurat, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showQRCode(BuildContext context, TemplateEntity template) {
    // In a real app, this URL would point to the web deployment of the form
    final formUrl = "https://sipintar-desa.web.app/#/form?id=${template.id}&kode=${template.kodeSurat}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan untuk Isi Form ${template.namaSurat}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(
                data: formUrl,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scan menggunakan HP Anda untuk mengisi data.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuratFormPage(
                      templateId: template.id,
                      namaSurat: template.namaSurat,
                      kodeSurat: template.kodeSurat,
                    ),
                  ),
                );
              },
              child: const Text('Atau Klik di Sini (Hanya untuk Demo)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
