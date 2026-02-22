import 'dart:typed_data';
import 'package:docx_template/docx_template.dart';
import '../../features/surat/domain/surat_request_entity.dart';

class DocxHelper {
  static Future<Uint8List> generateSurat({
    required Uint8List templateBytes,
    required SuratRequestEntity request,
  }) async {
    final docx = await DocxTemplate.fromBytes(templateBytes);
    
    // Create map for replacement tags in .docx
    // Tags in docx should be like {nama}, {nik}, {nomor_surat}, etc.
    final Content content = Content();
    
    // Basic Data
    content.add(TextContent("jenis_surat", request.jenisSurat));
    content.add(TextContent("nomor_surat", request.nomorSurat ?? "-"));
    
    // Form Data
    request.formData.forEach((key, value) {
      content.add(TextContent(key, value.toString()));
    });

    // Date Data
    final now = DateTime.now();
    content.add(TextContent("tahun", now.year.toString()));
    content.add(TextContent("tanggal_approve", "${now.day}/${now.month}/${now.year}"));

    final docxGenerated = await docx.generate(content);
    
    if (docxGenerated == null) throw "Gagal generate DOCX";
    
    return Uint8List.fromList(docxGenerated);
  }
}
