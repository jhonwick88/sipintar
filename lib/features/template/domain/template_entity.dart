import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateEntity {
  final String id;
  final String namaSurat;
  final String kodeSurat;
  final String fileUrl;
  final bool aktif;
  final DateTime createdAt;

  const TemplateEntity({
    required this.id,
    required this.namaSurat,
    required this.kodeSurat,
    required this.fileUrl,
    required this.aktif,
    required this.createdAt,
  });
}
