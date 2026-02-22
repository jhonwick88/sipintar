import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../surat/domain/surat_request_entity.dart';
import '../../../../shared/widgets/request_detail_dialog.dart';

class RequestListView extends StatelessWidget {
  final AsyncValue<List<SuratRequestEntity>> asyncRequests;

  const RequestListView({super.key, required this.asyncRequests});

  @override
  Widget build(BuildContext context) {
    return asyncRequests.when(
      data: (requests) {
        if (requests.isEmpty) return const Center(child: Text('Tidak ada data.'));
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.description)),
              title: Text(request.jenisSurat),
              subtitle: Text("${request.formData['nama']} - ${request.phone}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDetail(context, request),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showDetail(BuildContext context, SuratRequestEntity request) {
    showDialog(
      context: context,
      builder: (context) => RequestDetailDialog(request: request),
    );
  }
}
