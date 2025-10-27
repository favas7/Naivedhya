// lib/Views/admin/vendors/vendor_details_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/vendors/widgets/add_worker_dialog.dart';
import 'package:naivedhya/Views/admin/vendors/widgets/worker_card.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/models/worker_model.dart';
import 'package:naivedhya/services/ventor_Service.dart';
import 'package:naivedhya/services/worker_service.dart';
import 'package:naivedhya/utils/color_theme.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String vendorId;

  const VendorDetailsScreen({
    super.key,
    required this.vendorId,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  final VendorService _vendorService = VendorService();
  final WorkerService _workerService = WorkerService();

  Vendor? _vendor;
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = true;
  bool _isGridView = false;
  String _searchQuery = '';
  String _selectedEmploymentStatus = 'All';
  String _selectedShiftType = 'All';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🔷 [VENDOR DETAILS] _loadData() called');
    print('🆔 [VENDOR DETAILS] Loading data for vendor ID: ${widget.vendorId}');
    
    setState(() => _isLoading = true);

    try {
      print('📥 [VENDOR DETAILS] Fetching vendor details...');
      _vendor = await _vendorService.getVendorDetails(widget.vendorId);
      
      if (_vendor == null) {
        print('❌ [VENDOR DETAILS] ERROR: Vendor not found!');
        throw Exception('Vendor not found');
      }
      
      print('✅ [VENDOR DETAILS] Vendor loaded: ${_vendor!.name}');
      print('📧 [VENDOR DETAILS] Vendor email: ${_vendor!.email}');
      print('📞 [VENDOR DETAILS] Vendor phone: ${_vendor!.phone}');

      print('📥 [VENDOR DETAILS] Fetching workers...');
      _workers = await _workerService.getWorkersByVendor(widget.vendorId);
      _filteredWorkers = _workers;
      
      print('✅ [VENDOR DETAILS] Workers loaded: ${_workers.length} workers');
      
      if (_workers.isEmpty) {
        print('ℹ️ [VENDOR DETAILS] No workers found for this vendor');
      } else {
        print('👥 [VENDOR DETAILS] Worker list:');
        for (var i = 0; i < _workers.length; i++) {
          print('  ${i + 1}. ${_workers[i].name} (${_workers[i].role})');
        }
      }

      setState(() => _isLoading = false);
      print('✅ [VENDOR DETAILS] Data loading complete');
      
    } catch (e, stackTrace) {
      print('❌ [VENDOR DETAILS] ERROR loading data!');
      print('❌ [VENDOR DETAILS] Error: $e');
      print('❌ [VENDOR DETAILS] Stack trace: $stackTrace');
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error loading data', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$e', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _filterWorkers() {
    List<Worker> filtered = _workers;

    // Filter by employment status
    if (_selectedEmploymentStatus != 'All') {
      filtered = filtered
          .where((w) => w.employmentStatus == _selectedEmploymentStatus)
          .toList();
    }

    // Filter by shift type
    if (_selectedShiftType != 'All') {
      filtered = filtered.where((w) => w.shiftType == _selectedShiftType).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((w) {
        return w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.phone.contains(_searchQuery);
      }).toList();
    }

    setState(() => _filteredWorkers = filtered);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterWorkers();
  }

  void _onEmploymentStatusChanged(String? status) {
    setState(() => _selectedEmploymentStatus = status ?? 'All');
    _filterWorkers();
  }

  void _onShiftTypeChanged(String? shift) {
    setState(() => _selectedShiftType = shift ?? 'All');
    _filterWorkers();
  }

  Future<void> _showAddWorkerDialog() async {
    print('🔷 [VENDOR DETAILS] _showAddWorkerDialog() called');
    
    if (_vendor == null) {
      print('❌ [VENDOR DETAILS] ERROR: Vendor is null!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Vendor data not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('✅ [VENDOR DETAILS] Vendor loaded: ${_vendor!.name}');
    print('🆔 [VENDOR DETAILS] Vendor ID: ${widget.vendorId}');
    print('📂 [VENDOR DETAILS] Opening Add Worker Dialog...');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        print('🏗️ [VENDOR DETAILS] Building AddWorkerDialog widget...');
        return AddWorkerDialog(
          vendorId: widget.vendorId,
          vendorName: _vendor!.name,
        );
      },
    );

    print('🔙 [VENDOR DETAILS] Dialog closed. Result: $result');

    if (result == true) {
      print('✅ [VENDOR DETAILS] Worker saved successfully. Reloading data...');
      _loadData();
    } else {
      print('ℹ️ [VENDOR DETAILS] Dialog cancelled or no changes');
    }
  }

  Future<void> _showEditWorkerDialog(Worker worker) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddWorkerDialog(
        vendorId: widget.vendorId,
        vendorName: _vendor!.name,
        worker: worker,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteWorker(Worker worker, {bool hardDelete = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hardDelete ? 'Permanently Delete Worker' : 'Deactivate Worker'),
        content: Text(
          hardDelete
              ? 'Are you sure you want to permanently delete "${worker.name}"? This action cannot be undone.'
              : 'Are you sure you want to deactivate "${worker.name}"? You can reactivate them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(hardDelete ? 'Permanently Delete' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && worker.id != null) {
      try {
        if (hardDelete) {
          await _workerService.deleteWorker(worker.id!);
        } else {
          await _workerService.deactivateWorker(worker.id!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hardDelete
                    ? 'Worker deleted permanently'
                    : 'Worker deactivated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _reactivateWorker(Worker worker) async {
    if (worker.id == null) return;

    try {
      await _workerService.reactivateWorker(worker.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker reactivated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: _isLoading ? _buildLoading(colors) : _buildContent(colors),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerDialog,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Worker'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppThemeColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _vendor?.name ?? 'Vendor Details',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_vendor != null)
            Text(
              _vendor!.serviceType,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.list : Icons.grid_view,
            color: colors.textPrimary,
          ),
          onPressed: () => setState(() => _isGridView = !_isGridView),
          tooltip: _isGridView ? 'List View' : 'Grid View',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colors.textSecondary.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildLoading(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading Workers...',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppThemeColors colors) {
    return Column(
      children: [
        // Vendor Info Card
        _buildVendorInfoCard(colors),

        // Filters
        _buildFilters(colors),

        // Stats Bar
        _buildStatsBar(colors),

        // Workers List/Grid
        Expanded(
          child: _filteredWorkers.isEmpty
              ? _buildEmptyState(colors)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: colors.primary,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
        ),
      ],
    );
  }

  Widget _buildVendorInfoCard(AppThemeColors colors) {
    if (_vendor == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _vendor!.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _vendor!.serviceType,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.textSecondary.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  colors,
                  Icons.email_outlined,
                  _vendor!.email,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  colors,
                  Icons.phone_outlined,
                  _vendor!.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(AppThemeColors colors, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(AppThemeColors colors) {
    final employmentStatuses = ['All', 'Active', 'Inactive', 'On Leave'];
    final shiftTypes = ['All', 'Morning', 'Evening', 'Night', 'Rotating'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search workers...',
                hintStyle: TextStyle(color: colors.textSecondary),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Employment Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedEmploymentStatus,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              items: employmentStatuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: _onEmploymentStatusChanged,
            ),
          ),
          const SizedBox(width: 12),

          // Shift Type Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedShiftType,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              items: shiftTypes.map((shift) {
                return DropdownMenuItem(value: shift, child: Text(shift));
              }).toList(),
              onChanged: _onShiftTypeChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(AppThemeColors colors) {
    final activeCount = _workers.where((w) => w.isActive).length;
    final inactiveCount = _workers.where((w) => !w.isActive).length;
    final onLeaveCount =
        _workers.where((w) => w.employmentStatus == 'On Leave').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(colors, 'Total', _workers.length.toString(),
              Icons.people, colors.primary),
          _buildStatItem(
              colors, 'Active', activeCount.toString(), Icons.check_circle, colors.success),
          _buildStatItem(colors, 'Inactive', inactiveCount.toString(),
              Icons.cancel, colors.error),
          _buildStatItem(colors, 'On Leave', onLeaveCount.toString(),
              Icons.event_busy, colors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppThemeColors colors, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = _filteredWorkers[index];
        return WorkerCard(
          worker: worker,
          onEdit: () => _showEditWorkerDialog(worker),
          onDelete: () => _deleteWorker(worker),
          onHardDelete: () => _deleteWorker(worker, hardDelete: true),
          onReactivate: worker.isActive ? null : () => _reactivateWorker(worker),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = _filteredWorkers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WorkerCard(
            worker: worker,
            onEdit: () => _showEditWorkerDialog(worker),
            onDelete: () => _deleteWorker(worker),
            onHardDelete: () => _deleteWorker(worker, hardDelete: true),
            onReactivate: worker.isActive ? null : () => _reactivateWorker(worker),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _workers.isEmpty ? Icons.person_add : Icons.search_off,
              size: 60,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _workers.isEmpty ? 'No Workers Yet' : 'No workers found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _workers.isEmpty
                ? 'Start by adding your first worker'
                : 'Try adjusting your search or filters',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          if (_workers.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddWorkerDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Worker'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}