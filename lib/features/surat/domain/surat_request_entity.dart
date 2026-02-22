import 'package:cloud_firestore/cloud_firestore.dart';

class SuratRequestEntity {
  final String id;
  final String jenisSurat;
  final String templateId;
  final Map<String, dynamic> formData;
  final String phone;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? nomorSurat;

  const SuratRequestEntity({
    required this.id,
    required this.jenisSurat,
    required this.templateId,
    required this.formData,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.nomorSurat,
  });
}
