import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../data/template_model.dart';
import '../domain/template_entity.dart';

abstract class TemplateRepository {
  Stream<List<TemplateEntity>> getTemplates();
  Future<void> addTemplate(TemplateModel template, Uint8List fileBytes);
  Future<void> updateTemplate(TemplateModel template);
  Future<void> deleteTemplate(String id);
}

class TemplateRepositoryImpl implements TemplateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<TemplateEntity>> getTemplates() {
    return _firestore.collection(AppConstants.templatesPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addTemplate(TemplateModel template, Uint8List fileBytes) async {
    // 1. Upload file to Storage
    final ref = _storage.ref().child('templates/${template.kodeSurat}.docx');
    await ref.putData(fileBytes);
    final url = await ref.getDownloadURL();

    // 2. Save metadata to Firestore
    final finalTemplate = TemplateModel(
      id: '',
      namaSurat: template.namaSurat,
      kodeSurat: template.kodeSurat,
      fileUrl: url,
      aktif: template.aktif,
      createdAt: template.createdAt,
    );
    await _firestore.collection(AppConstants.templatesPath).add(finalTemplate.toMap());
  }

  @override
  Future<void> updateTemplate(TemplateModel template) async {
    await _firestore.collection(AppConstants.templatesPath).doc(template.id).update(template.toMap());
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _firestore.collection(AppConstants.templatesPath).doc(id).delete();
  }
}
