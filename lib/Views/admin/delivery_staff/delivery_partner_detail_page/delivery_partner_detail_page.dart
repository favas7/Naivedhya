// views/admin/delivery_staff/delivery_partner_detail_page.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_partner_detail_page/widgets/delivery_analytics_widget.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_partner_detail_page/widgets/delivery_documents_widget.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_partner_detail_page/widgets/delivery_history_widget.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_partner_detail_page/widgets/delivery_info_card.dart';
import 'package:naivedhya/models/delivery_history_model.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class DeliveryPartnerDetailPage extends StatefulWidget {
  final String userId;

  const DeliveryPartnerDetailPage({
    super.key,
    required this.userId,
  });

  @override
  State<DeliveryPartnerDetailPage> createState() => _DeliveryPartnerDetailPageState();
}

class _DeliveryPartnerDetailPageState extends State<DeliveryPartnerDetailPage>
    with SingleTickerProviderStateMixin {
  final DeliveryPersonnelService _service = DeliveryPersonnelService();
  late TabController _tabController;
  
  DeliveryPersonnel? _deliveryPerson;
  List<DeliveryHistory> _deliveryHistory = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch detailed delivery personnel data
      final person = await _service.fetchDetailedDeliveryPersonnel(widget.userId);
      
      // Fetch delivery history
      final history = await _service.fetchDeliveryHistory(widget.userId, limit: 100);
      
      // Fetch statistics for last 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final stats = await _service.fetchDeliveryStatistics(
        widget.userId,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _deliveryPerson = person;
        _deliveryHistory = history;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: _isLoading
          ? _buildLoading(colors)
          : _error != null
              ? _buildError(colors)
              : _buildContent(colors),
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
            'Loading delivery partner details...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppThemeColors colors) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(colors),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeaderSection(colors),
              _buildTabBar(colors),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(colors),
              _buildHistoryTab(colors),
              _buildDocumentsTab(colors),
              _buildAnalyticsTab(colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(AppThemeColors colors) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: colors.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () => _showEditDialog(),
          icon: const Icon(Icons.edit, color: Colors.white),
          tooltip: 'Edit',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_availability',
              child: Row(
                children: [
                  Icon(
                    _deliveryPerson!.isAvailable 
                        ? Icons.visibility_off 
                        : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _deliveryPerson!.isAvailable 
                        ? 'Mark Unavailable' 
                        : 'Mark Available',
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'verify',
              child: Row(
                children: [
                  Icon(
                    _deliveryPerson!.isVerified 
                        ? Icons.verified 
                        : Icons.verified_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _deliveryPerson!.isVerified 
                        ? 'Unverify' 
                        : 'Verify',
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Block/Suspend', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                colors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _deliveryPerson!.displayName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (_deliveryPerson!.isVerified)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.verified,
                                      size: 20,
                                      color: colors.success,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _deliveryPerson!.vehicleInfo,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              colors,
              Icons.star,
              _deliveryPerson!.rating.toStringAsFixed(1),
              'Rating',
              colors.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              colors,
              Icons.local_shipping,
              _deliveryPerson!.totalDeliveries.toString(),
              'Deliveries',
              colors.info,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              colors,
              Icons.payments,
              '₹${_deliveryPerson!.earnings.toStringAsFixed(0)}',
              'Earnings',
              colors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              colors,
              Icons.shopping_bag,
              _deliveryPerson!.activeOrdersCount.toString(),
              'Active Orders',
              _deliveryPerson!.isAvailable ? colors.success : colors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    AppThemeColors colors,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colors.primary,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: colors.primary,
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
          Tab(text: 'History', icon: Icon(Icons.history)),
          Tab(text: 'Documents', icon: Icon(Icons.description)),
          Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AppThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DeliveryInfoCard(
        deliveryPerson: _deliveryPerson!,
        onEdit: _showEditDialog,
        onToggleAvailability: _handleToggleAvailability,
      ),
    );
  }

  Widget _buildHistoryTab(AppThemeColors colors) {
    return DeliveryHistoryWidget(
      deliveryHistory: _deliveryHistory,
      onRefresh: _loadData,
    );
  }

  Widget _buildDocumentsTab(AppThemeColors colors) {
    return DeliveryDocumentsWidget(
      deliveryPerson: _deliveryPerson!,
      onVerify: () => _handleVerification(true),
      onReject: () => _handleVerification(false),
    );
  }

  Widget _buildAnalyticsTab(AppThemeColors colors) {
    return DeliveryAnalyticsWidget(
      statistics: _statistics ?? {},
      deliveryHistory: _deliveryHistory,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'toggle_availability':
        _handleToggleAvailability();
        break;
      case 'verify':
        _handleVerification(!_deliveryPerson!.isVerified);
        break;
      case 'block':
        _showBlockDialog();
        break;
    }
  }

  Future<void> _handleToggleAvailability() async {
    try {
      await context.read<DeliveryPersonnelProvider>()
          .toggleAvailability(_deliveryPerson!.userId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Availability updated to ${!_deliveryPerson!.isAvailable ? "Available" : "Unavailable"}',
            ),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  Future<void> _handleVerification(bool verify) async {
    try {
      await _service.updateVerificationStatus(
        _deliveryPerson!.userId,
        verify,
        verify ? 'verified' : 'rejected',
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verify ? 'Partner verified successfully' : 'Verification rejected'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  void _showEditDialog() {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Delivery Partner'),
        content: Text(
          'Are you sure you want to block ${_deliveryPerson!.displayName}? '
          'They will not be able to accept new deliveries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Block feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}