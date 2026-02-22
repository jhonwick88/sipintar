import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/surat_request_entity.dart';

class SuratRequestModel extends SuratRequestEntity {
  const SuratRequestModel({
    required super.id,
    required super.jenisSurat,
    required super.templateId,
    required super.formData,
    required super.phone,
    required super.status,
    required super.createdAt,
    super.approvedAt,
    super.approvedBy,
    super.nomorSurat,
  });

  factory SuratRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return SuratRequestModel(
      id: id,
      jenisSurat: map['jenisSurat'] ?? '',
      templateId: map['templateId'] ?? '',
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      approvedAt: map['approvedAt'] != null ? (map['approvedAt'] as Timestamp).toDate() : null,
      approvedBy: map['approvedBy'],
      nomorSurat: map['nomorSurat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jenisSurat': jenisSurat,
      'templateId': templateId,
      'formData': formData,
      'phone': phone,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'nomorSurat': nomorSurat,
    };
  }
}
