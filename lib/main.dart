import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sipintar/features/auth/presentation/auth_provider.dart';
import 'package:sipintar/features/auth/presentation/role_guard.dart';
import 'package:sipintar/features/dashboard/presentation/dashboard_page.dart';
import 'package:sipintar/features/surat/presentation/landing_page.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCxZIwgabRlOhb5rv6SceSMBnfmyGdmvug",
        authDomain: "sipintar-4c1da.firebaseapp.com",
        projectId: "sipintar-4c1da",
        storageBucket: "sipintar-4c1da.firebasestorage.app",
        messagingSenderId: "3355086623",
        appId: "1:3355086623:web:c2a101783183cb7a11aa2a",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: MyApp()));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sipintar Desa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConsumerEntryPoint(),
    );
  }
}

class ConsumerEntryPoint extends ConsumerWidget {
  const ConsumerEntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LandingPage();
        return const RoleGuard(
          allowedRoles: ['admin', 'dev'],
          child: DashboardPage(),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
