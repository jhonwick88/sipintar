import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../features/surat/domain/surat_request_entity.dart';
import '../../features/surat/presentation/surat_provider.dart';
import '../../features/template/presentation/template_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../../core/utils/docx_helper.dart';
import '../../../core/utils/wa_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

class RequestDetailDialog extends ConsumerStatefulWidget {
  final SuratRequestEntity request;

  const RequestDetailDialog({super.key, required this.request});

  @override
  ConsumerState<RequestDetailDialog> createState() => _RequestDetailDialogState();
}

class _RequestDetailDialogState extends ConsumerState<RequestDetailDialog> {
  bool _isLoading = false;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.request.formData.map(
      (key, value) => MapEntry(key, TextEditingController(text: value.toString())),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detail: ${widget.request.jenisSurat}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Data Pemohon (Dapat Diedit):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            ..._controllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: e.value,
                decoration: InputDecoration(
                  labelText: e.key.toUpperCase().replaceAll('_', ' '),
                  border: const OutlineInputBorder(),
                ),
              ),
            )),
            const Divider(),
            _buildInfoRow('No WA', widget.request.phone),
            _buildInfoRow('Status', widget.request.status),
          ],
        ),
      ),
      actions: [
        if (widget.request.status == 'pending') ...[
          ElevatedButton(
            onPressed: _isLoading ? null : () => _handleApproval(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('APPROVE & GENERATE'),
          ),
          TextButton(
            onPressed: _isLoading ? null : () => _handleRejection(context),
            child: const Text('REJECT', style: TextStyle(color: Colors.red)),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('TUTUP'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _handleApproval(BuildContext context) async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(userRoleProvider).value;
      if (user == null) throw "Admin tidak terautentikasi";

      // 1. Ambil Data yang Sudah Diedit
      final updatedFormData = _controllers.map((key, value) => MapEntry(key, value.text));

      // 2. Ambil Template Metadata
      final templates = ref.read(templatesProvider).value ?? [];
      final template = templates.firstWhere((t) => t.id == widget.request.templateId);

      // 3. Download File Template .docx
      final response = await http.get(Uri.parse(template.fileUrl));
      if (response.statusCode != 200) throw "Gagal download template";

      // 4. Jalankan Transaksi untuk Nomor Surat
      final formattedNumber = await ref.read(suratRepositoryProvider).approveRequest(
        widget.request.id, 
        template.kodeSurat, 
        user.uid
      );

      // 5. Generate DOCX dengan data Terbaru
      final updatedRequest = SuratRequestEntity(
        id: widget.request.id,
        jenisSurat: widget.request.jenisSurat,
        templateId: widget.request.templateId,
        formData: updatedFormData,
        phone: widget.request.phone,
        status: 'approved',
        createdAt: widget.request.createdAt,
        nomorSurat: formattedNumber,
      );
      
      final generatedBytes = await DocxHelper.generateSurat(
        templateBytes: response.bodyBytes, 
        request: updatedRequest,
      );

      // 6. Preview & Share
      final xFile = XFile.fromData(generatedBytes, name: 'Surat_${template.kodeSurat}_$formattedNumber.docx');
      await Share.shareXFiles([xFile], text: 'Surat ${widget.request.jenisSurat}');

      // 7. Buka WA
      final message = "Halo ${updatedFormData['nama'] ?? 'Warga'}, permohonan surat ${widget.request.jenisSurat} Anda telah DISETUJUI dengan nomor $formattedNumber.";
      await WaHelper.sendMessage(widget.request.phone, message);

      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRejection(BuildContext context) async {
     try {
      await ref.read(suratRepositoryProvider).rejectRequest(widget.request.id);
      final name = _controllers['nama']?.text ?? 'Warga';
      final message = "Mohon maaf $name, permohonan surat ${widget.request.jenisSurat} Anda DITOLAK.";
      await WaHelper.sendMessage(widget.request.phone, message);
      if (mounted) Navigator.pop(context);
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

  }
}
