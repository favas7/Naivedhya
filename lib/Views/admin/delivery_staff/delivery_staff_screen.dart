import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_partner_detail_page/delivery_partner_detail_page.dart';
import 'package:naivedhya/Views/admin/delivery_staff/widgets/delivery_staff_card.dart';
import 'package:naivedhya/Views/admin/delivery_staff/widgets/dialogue_components.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class DeliveryStaffScreen extends StatefulWidget {
  const DeliveryStaffScreen({super.key});

  @override
  State<DeliveryStaffScreen> createState() => _DeliveryStaffScreenState();
}

class _DeliveryStaffScreenState extends State<DeliveryStaffScreen> {
  bool _isGridView = true;
  String _selectedFilter = 'all'; // all, available, busy, verified

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
    });
  }

  List<DeliveryPersonnel> _getFilteredStaff(List<DeliveryPersonnel> allStaff) {
    switch (_selectedFilter) {
      case 'available':
        return allStaff.where((s) => s.isAvailable && s.assignedOrders.isEmpty).toList();
      case 'busy':
        return allStaff.where((s) => !s.isAvailable || s.assignedOrders.isNotEmpty).toList();
      case 'verified':
        return allStaff.where((s) => s.isVerified).toList();
      case 'unverified':
        return allStaff.where((s) => !s.isVerified).toList();
      default:
        return allStaff;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: Consumer<DeliveryPersonnelProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoading(colors);
                }

                final filteredStaff = _getFilteredStaff(provider.deliveryPersonnel);
                
                if (filteredStaff.isEmpty) {
                  return _buildEmptyState(colors, provider.deliveryPersonnel.isEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchDeliveryPersonnel(),
                  color: colors.primary,
                  child: Column(
                    children: [
                      _buildStatsBar(colors, provider.deliveryPersonnel),
                      Expanded(
                        child: _isGridView
                            ? _buildGridView(filteredStaff, provider)
                            : _buildListView(filteredStaff, provider),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DeliveryStaffDialogs.showSearchDialog(context),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: const Text('Search'),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Staff',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<DeliveryPersonnelProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          '${provider.deliveryPersonnel.length} ${provider.deliveryPersonnel.length == 1 ? 'Staff Member' : 'Staff Members'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // View Toggle
              Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isGridView = true),
                      icon: Icon(
                        Icons.grid_view,
                        color: _isGridView ? colors.primary : colors.textSecondary,
                      ),
                      tooltip: 'Grid View',
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = false),
                      icon: Icon(
                        Icons.view_list,
                        color: !_isGridView ? colors.primary : colors.textSecondary,
                      ),
                      tooltip: 'List View',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
                },
                icon: Icon(Icons.refresh, color: colors.textSecondary),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(colors, 'All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Available', 'available', Colors.green),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Busy', 'busy', Colors.orange),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Verified', 'verified', Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Unverified', 'unverified', Colors.grey),
                const SizedBox(width: 16),
                // Action Buttons
                OutlinedButton.icon(
                  onPressed: () => DeliveryStaffDialogs.showSearchDialog(context),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => DeliveryStaffDialogs.showFilterDialog(context),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    side: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AppThemeColors colors, String label, String value, [Color? color]) {
    final isSelected = _selectedFilter == value;
    final chipColor = color ?? colors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? value : 'all');
      },
      backgroundColor: colors.background,
      selectedColor: chipColor.withOpacity(0.15),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor.withOpacity(0.5) : colors.textSecondary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildStatsBar(AppThemeColors colors, List<DeliveryPersonnel> allStaff) {
    final available = allStaff.where((s) => s.isAvailable && s.assignedOrders.isEmpty).length;
    final onDelivery = allStaff.where((s) => s.assignedOrders.isNotEmpty).length;
    final verified = allStaff.where((s) => s.isVerified).length;
    final totalEarnings = allStaff.fold<double>(0, (sum, s) => sum + s.earnings);

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
          _buildStatItem(colors, 'Total', allStaff.length.toString(), Icons.people, colors.primary),
          _buildStatItem(colors, 'Available', available.toString(), Icons.check_circle, colors.success),
          _buildStatItem(colors, 'On Delivery', onDelivery.toString(), Icons.local_shipping, colors.info),
          _buildStatItem(colors, 'Verified', verified.toString(), Icons.verified, colors.success),
          _buildStatItem(colors, 'Earnings', '₹${totalEarnings.toStringAsFixed(0)}', Icons.payments, colors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppThemeColors colors, String label, String value, IconData icon, Color color) {
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

  Widget _buildLoading(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading Staff...',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors colors, bool isCompletelyEmpty) {
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
              isCompletelyEmpty ? Icons.delivery_dining : Icons.search_off,
              size: 60,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isCompletelyEmpty ? 'No Delivery Staff Yet' : 'No staff found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCompletelyEmpty
                ? 'Add your first delivery staff member'
                : 'Try adjusting your filters',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          if (_selectedFilter != 'all') ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _selectedFilter = 'all'),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildGridView(List<DeliveryPersonnel> staff, DeliveryPersonnelProvider provider) {
  return GridView.builder(
    padding: const EdgeInsets.all(24),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 400,
      childAspectRatio: 1.0,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      mainAxisExtent: 300,
    ),
    itemCount: staff.length,
    itemBuilder: (context, index) {
      final member = staff[index];
      return DeliveryStaffCard(
        staff: member,
        onToggleAvailability: () => provider.toggleAvailability(member.userId),
        onViewDetails: () => _navigateToDetailPage(context, member.userId), // UPDATED
        onViewOrders: () => _showOrdersDialog(context, member, provider),
        onVerify: () => _showVerifyDialog(context, member),
      );
    },
  );
}

Widget _buildListView(List<DeliveryPersonnel> staff, DeliveryPersonnelProvider provider) {
  return ListView.builder(
    padding: const EdgeInsets.all(24),
    itemCount: staff.length,
    itemBuilder: (context, index) {
      final member = staff[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DeliveryStaffCard(
          staff: member,
          onToggleAvailability: () => provider.toggleAvailability(member.userId),
          onViewDetails: () => _navigateToDetailPage(context, member.userId), // UPDATED
          onViewOrders: () => _showOrdersDialog(context, member, provider),
          onVerify: () => _showVerifyDialog(context, member),
        ),
      );
    },
  );
}

void _navigateToDetailPage(BuildContext context, String userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DeliveryPartnerDetailPage(userId: userId),
    ),
  );
}




  void _showOrdersDialog(BuildContext context, DeliveryPersonnel staff, DeliveryPersonnelProvider provider) {
    final colors = AppTheme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${staff.displayName}\'s Orders'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: staff.assignedOrders.isEmpty
              ? const Center(child: Text('No assigned orders'))
              : ListView.builder(
                  itemCount: staff.assignedOrders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.receipt, color: colors.primary),
                      title: Text('Order #${staff.assignedOrders[index]}'),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: colors.error),
                        onPressed: () {
                          provider.unassignOrder(staff.assignedOrders[index], staff.userId);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, DeliveryPersonnel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Staff Member'),
        content: Text('Mark ${staff.displayName} as verified?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement verification
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}