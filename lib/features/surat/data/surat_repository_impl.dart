import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_helper.dart';
import '../domain/surat_request_entity.dart';
import 'surat_request_model.dart';

abstract class SuratRepository {
  Stream<List<SuratRequestEntity>> getRequestsByStatus(String status);
  Future<void> submitRequest(SuratRequestModel request);
  Future<String> approveRequest(String requestId, String kodeSurat, String adminId);
  Future<void> rejectRequest(String requestId);
}

class SuratRepositoryImpl implements SuratRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<SuratRequestEntity>> getRequestsByStatus(String status) {
    return _firestore.collection(AppConstants.requestsPath)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SuratRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> submitRequest(SuratRequestModel request) async {
    await _firestore.collection(AppConstants.requestsPath).add(request.toMap());
  }

  @override
  Future<String> approveRequest(String requestId, String kodeSurat, String adminId) async {
    final year = DateTime.now().year;
    final counterId = "${kodeSurat}_$year";
    final counterRef = _firestore.collection(AppConstants.countersPath).doc(counterId);
    final requestRef = _firestore.collection(AppConstants.requestsPath).doc(requestId);

    return _firestore.runTransaction((transaction) async {
      // 1. Get current counter
      final counterDoc = await transaction.get(counterRef);
      int nextNumber = 1;
      
      if (counterDoc.exists) {
        nextNumber = (counterDoc.data()?['lastNumber'] ?? 0) + 1;
      }

      // 2. Generate nomor surat format: 140/{noUrut}/DS-SKM/{bulanRomawi}/{tahun}
      final romanMonth = DateHelper.getRomanMonth(DateTime.now().month);
      final formattedNumber = "140/$nextNumber/DS-$kodeSurat/$romanMonth/$year";

      // 3. Update counter
      transaction.set(counterRef, {'lastNumber': nextNumber});

      // 4. Update request
      transaction.update(requestRef, {
        'status': 'approved',
        'nomorSurat': formattedNumber,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
      });

      return formattedNumber;
    });
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection(AppConstants.requestsPath).doc(requestId).update({
      'status': 'rejected',
    });
  }
}
