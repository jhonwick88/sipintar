import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../surat/presentation/surat_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/utils/responsive_layout.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/request_list_view.dart';
import '../../template/presentation/template_management_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      web: _buildWebLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.description), label: Text('Template')),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  icon: const Icon(Icons.logout),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _getContent()),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('SIPINTAR ADMIN')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.description), label: Text('Template')),
            ],
          ),
          Expanded(child: _getContent()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('SIPINTAR ADMIN')),
      body: _getContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Template'),
        ],
      ),
    );
  }

  Widget _getContent() {
    if (_selectedIndex == 1) return const TemplateManagementPage();
    
    final pending = ref.watch(pendingRequestsProvider);
    final approved = ref.watch(approvedRequestsProvider);
    final rejected = ref.watch(rejectedRequestsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetrics(pending, approved, rejected),
          const SizedBox(height: 32),
          const Text('Daftar Permohonan Pending', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 500, child: RequestListView(asyncRequests: pending)),
        ],
      ),
    );
  }

  Widget _buildMetrics(var pending, var approved, var rejected) {
    return LayoutBuilder(builder: (context, constraints) {
      return GridView.count(
        crossAxisCount: constraints.maxWidth > 800 ? 3 : 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          DashboardCard(
            title: 'Pending',
            count: pending.maybeWhen(data: (d) => d.length, orElse: () => 0),
            color: Colors.orange,
            icon: Icons.pending_actions,
          ),
          DashboardCard(
            title: 'Approved',
            count: approved.maybeWhen(data: (d) => d.length, orElse: () => 0),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          DashboardCard(
            title: 'Rejected',
            count: rejected.maybeWhen(data: (d) => d.length, orElse: () => 0),
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ],
      );
    });
  }
}
