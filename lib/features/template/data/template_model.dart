import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/template_entity.dart';

class TemplateModel extends TemplateEntity {
  const TemplateModel({
    required super.id,
    required super.namaSurat,
    required super.kodeSurat,
    required super.fileUrl,
    required super.aktif,
    required super.createdAt,
  });

  factory TemplateModel.fromMap(Map<String, dynamic> map, String id) {
    return TemplateModel(
      id: id,
      namaSurat: map['namaSurat'] ?? '',
      kodeSurat: map['kodeSurat'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      aktif: map['aktif'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaSurat': namaSurat,
      'kodeSurat': kodeSurat,
      'fileUrl': fileUrl,
      'aktif': aktif,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
