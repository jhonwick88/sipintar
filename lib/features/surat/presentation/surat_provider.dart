import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/surat_repository_impl.dart';
import '../domain/surat_request_entity.dart';

final suratRepositoryProvider = Provider<SuratRepository>((ref) {
  return SuratRepositoryImpl();
});

final pendingRequestsProvider = StreamProvider<List<SuratRequestEntity>>((ref) {
  return ref.read(suratRepositoryProvider).getRequestsByStatus('pending');
});

final approvedRequestsProvider = StreamProvider<List<SuratRequestEntity>>((ref) {
  return ref.read(suratRepositoryProvider).getRequestsByStatus('approved');
});

final rejectedRequestsProvider = StreamProvider<List<SuratRequestEntity>>((ref) {
  return ref.read(suratRepositoryProvider).getRequestsByStatus('rejected');
});
