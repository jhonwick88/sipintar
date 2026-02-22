import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/template_repository_impl.dart';
import '../domain/template_entity.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepositoryImpl();
});

final templatesProvider = StreamProvider<List<TemplateEntity>>((ref) {
  return ref.read(templateRepositoryProvider).getTemplates();
});

final activeTemplatesProvider = StreamProvider<List<TemplateEntity>>((ref) {
  return ref.read(templateRepositoryProvider).getTemplates().map(
    (templates) => templates.where((t) => t.aktif).toList(),
  );
});

