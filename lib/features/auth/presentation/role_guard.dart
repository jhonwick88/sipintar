import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'login_page.dart';

class RoleGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    super.key, 
    required this.child, 
    required this.allowedRoles
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      data: (user) {
        if (user == null) return const LoginPage();
        if (allowedRoles.contains(user.role)) {
          return child;
        }
        return const Scaffold(
          body: Center(child: Text('Akses Ditolak: Anda tidak memiliki wewenang.')),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
