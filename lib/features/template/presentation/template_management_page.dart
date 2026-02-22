import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../presentation/template_provider.dart';
import '../data/template_model.dart';
import 'dart:typed_data';

class TemplateManagementPage extends ConsumerStatefulWidget {
  const TemplateManagementPage({super.key});

  @override
  ConsumerState<TemplateManagementPage> createState() => _TemplateManagementPageState();
}

class _TemplateManagementPageState extends ConsumerState<TemplateManagementPage> {
  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Template Surat')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: templatesAsync.when(
        data: (templates) => ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final t = templates[index];
            return ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: Text(t.namaSurat),
              subtitle: Text(t.kodeSurat),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: t.aktif,
                    onChanged: (val) {
                      final updated = TemplateModel(
                        id: t.id,
                        namaSurat: t.namaSurat,
                        kodeSurat: t.kodeSurat,
                        fileUrl: t.fileUrl,
                        aktif: val,
                        createdAt: t.createdAt,
                      );
                      ref.read(templateRepositoryProvider).updateTemplate(updated);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(t.id),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddTemplateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    Uint8List? selectedFileBytes;
    String? fileName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Template Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Surat (Contoh: Surat Keterangan Domisili)'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Kode Surat (Contoh: SKD)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['docx'],
                  );
                  if (result != null) {
                    setDialogState(() {
                      selectedFileBytes = result.files.first.bytes;
                      fileName = result.files.first.name;
                    });
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: Text(fileName ?? 'Pilih File .docx'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
            ElevatedButton(
              onPressed: (selectedFileBytes == null || nameController.text.isEmpty || codeController.text.isEmpty)
                  ? null
                  : () async {
                      final template = TemplateModel(
                        id: '',
                        namaSurat: nameController.text,
                        kodeSurat: codeController.text,
                        fileUrl: '',
                        aktif: true,
                        createdAt: DateTime.now(),
                      );
                      await ref.read(templateRepositoryProvider).addTemplate(template, selectedFileBytes!);
                      if (mounted) Navigator.pop(context);
                    },
              child: const Text('SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Template?'),
        content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
          TextButton(
            onPressed: () async {
              await ref.read(templateRepositoryProvider).deleteTemplate(id);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text('HAPUS', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
