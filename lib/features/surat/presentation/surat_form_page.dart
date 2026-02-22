import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/surat_request_model.dart';
import 'surat_provider.dart';

class SuratFormPage extends ConsumerStatefulWidget {
  final String templateId;
  final String namaSurat;
  final String kodeSurat;

  const SuratFormPage({
    super.key, 
    required this.templateId, 
    required this.namaSurat, 
    required this.kodeSurat
  });

  @override
  ConsumerState<SuratFormPage> createState() => _SuratFormPageState();
}

class _SuratFormPageState extends ConsumerState<SuratFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _noKKController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noWAController = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form ${widget.namaSurat}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('No KK', _noKKController),
              _buildTextField('NIK', _nikController),
              _buildTextField('Nama Lengkap', _namaController),
              _buildTextField('Tanggal Lahir', _tglLahirController, hint: 'YYYY-MM-DD'),
              _buildTextField('Alamat', _alamatController, maxLines: 3),
              _buildTextField('No WhatsApp', _noWAController, hint: '0812xxxx'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting 
                    ? const CircularProgressIndicator() 
                    : const Text('SUBMIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final request = SuratRequestModel(
      id: '',
      jenisSurat: widget.namaSurat,
      templateId: widget.templateId,
      formData: {
        'no_kk': _noKKController.text,
        'nik': _nikController.text,
        'nama': _namaController.text,
        'tgl_lahir': _tglLahirController.text,
        'alamat': _alamatController.text,
      },
      phone: _noWAController.text,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(suratRepositoryProvider).submitRequest(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permohonan surat berhasil dikirim!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
