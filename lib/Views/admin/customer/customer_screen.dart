import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/customer/widgets/customer_card.dart';
import 'package:naivedhya/Views/admin/customer/widgets/customer_dialogs.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/services/customer_service.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _customers = [];
  List<UserModel> _filteredCustomers = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _selectedFilter = 'all'; // all, active, pending, new
  String _sortBy = 'name'; // name, orders, pending

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final customers = await _customerService.getAllCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
          _applyFiltersAndSort();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFiltersAndSort() {
    List<UserModel> filtered = _customers;

    // Apply filter
    switch (_selectedFilter) {
      case 'active':
        filtered = filtered
            .where((c) => (c.orderhistory?.length ?? 0) > 0)
            .toList();
        break;
      case 'pending':
        filtered = filtered
            .where((c) => (c.pendingpayments ?? 0) > 0)
            .toList();
        break;
      case 'new':
        filtered = filtered
            .where((c) => (c.orderhistory?.length ?? 0) == 0)
            .toList();
        break;
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.email.toLowerCase().contains(query) ||
            c.phone.toLowerCase().contains(query) ||
            (c.id ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'orders':
        filtered.sort((a, b) =>
            (b.orderhistory?.length ?? 0).compareTo(a.orderhistory?.length ?? 0));
        break;
      case 'pending':
        filtered.sort((a, b) =>
            (b.pendingpayments ?? 0).compareTo(a.pendingpayments ?? 0));
        break;
    }

    setState(() => _filteredCustomers = filtered);
  }

  void _onSearchChanged(String query) {
    _applyFiltersAndSort();
  }

  void _showEditDialog(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(
        customer: Customer.fromUserModel(customer),
        onCustomerUpdated: (updatedCustomer) async {
          await _loadCustomers();
        },
      ),
    );
  }

  Future<void> _deleteCustomer(UserModel customer) async {
    final confirmed = await CustomerDialogs.showDeleteConfirmation(
      context: context,
      customer: customer,
    );

    if (confirmed == true && mounted) {
      try {
        await _customerService.deleteCustomer(customer.id ?? '');
        if (mounted) {
          CustomerDialogs.showSuccessSnackbar(
            context: context,
            message: 'Customer deleted successfully',
          );
          _loadCustomers();
        }
      } catch (e) {
        if (mounted) {
          CustomerDialogs.showErrorSnackbar(
            context: context,
            message: 'Failed to delete: $e',
          );
        }
      }
    }
  }

  void _showCustomerDetails(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => _CustomerDetailsDialog(customer: customer),
    );
  }

  void _showOrdersDialog(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${customer.name}\'s Orders'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: (customer.orderhistory?.isEmpty ?? true)
              ? const Center(child: Text('No orders yet'))
              : ListView.builder(
                  itemCount: customer.orderhistory?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Order #${customer.orderhistory![index]}'),
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

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: _isLoading ? _buildLoading(colors) : _buildContent(colors),
          ),
        ],
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
                      'Customer Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_customers.length} ${_customers.length == 1 ? 'Customer' : 'Customers'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
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
                        color:
                            _isGridView ? colors.primary : colors.textSecondary,
                      ),
                      tooltip: 'Grid View',
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = false),
                      icon: Icon(
                        Icons.view_list,
                        color: !_isGridView
                            ? colors.primary
                            : colors.textSecondary,
                      ),
                      tooltip: 'List View',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadCustomers,
                icon: Icon(Icons.refresh, color: colors.textSecondary),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name, email, phone, or ID...',
              prefixIcon: Icon(Icons.search, color: colors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: colors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters and Sort Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filter Chips
                _buildFilterChip(colors, 'All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Active', 'active', Colors.green),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Pending', 'pending', Colors.red),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'New', 'new', Colors.blue),
                const SizedBox(width: 16),
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    icon: Icon(Icons.sort, color: colors.textSecondary),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                      DropdownMenuItem(value: 'orders', child: Text('Sort by Orders')),
                      DropdownMenuItem(value: 'pending', child: Text('Sort by Pending')),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value ?? 'name');
                      _applyFiltersAndSort();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AppThemeColors colors, String label, String value,
      [Color? color]) {
    final isSelected = _selectedFilter == value;
    final chipColor = color ?? colors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? value : 'all');
        _applyFiltersAndSort();
      },
      backgroundColor: colors.background,
      selectedColor: chipColor.withOpacity(0.15),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? chipColor.withOpacity(0.5)
            : colors.textSecondary.withOpacity(0.2),
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
            'Loading Customers...',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppThemeColors colors) {
    if (_filteredCustomers.isEmpty) {
      return _buildEmptyState(colors);
    }

    return RefreshIndicator(
      onRefresh: _loadCustomers,
      color: colors.primary,
      child: Column(
        children: [
          _buildStatsBar(colors),
          Expanded(
            child: _isGridView
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(AppThemeColors colors) {
    final activeCustomers =
        _customers.where((c) => (c.orderhistory?.length ?? 0) > 0).length;
    final totalPending = _customers.fold<double>(
        0, (sum, c) => sum + (c.pendingpayments ?? 0));
    final totalOrders = _customers.fold<int>(
        0, (sum, c) => sum + (c.orderhistory?.length ?? 0));

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
          _buildStatItem(colors, 'Total', _customers.length.toString(),
              Icons.people, colors.primary),
          _buildStatItem(colors, 'Active', activeCustomers.toString(),
              Icons.shopping_bag, colors.success),
          _buildStatItem(colors, 'Orders', totalOrders.toString(),
              Icons.receipt_long, colors.info),
          _buildStatItem(colors, 'Pending', '₹${totalPending.toStringAsFixed(0)}',
              Icons.payment, colors.error),
          _buildStatItem(colors, 'Showing', _filteredCustomers.length.toString(),
              Icons.visibility, colors.warning),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colors.textSecondary),
        ),
      ],
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
              _customers.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 60,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _customers.isEmpty ? 'No Customers Yet' : 'No customers found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _customers.isEmpty
                ? 'Customers will appear here'
                : 'Try adjusting your search or filters',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          if (_selectedFilter != 'all' || _searchController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedFilter = 'all');
                _applyFiltersAndSort();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,

      ),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return CustomerCard(
          customer: customer,
          onEdit: () => _showEditDialog(customer),
          onDelete: () => _deleteCustomer(customer),
          onViewDetails: () => _showCustomerDetails(customer),
          onViewOrders: () => _showOrdersDialog(customer),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CustomerCard(
            customer: customer,
            onEdit: () => _showEditDialog(customer),
            onDelete: () => _deleteCustomer(customer),
            onViewDetails: () => _showCustomerDetails(customer),
            onViewOrders: () => _showOrdersDialog(customer),
          ),
        );
      },
    );
  }
}

class _CustomerDetailsDialog extends StatelessWidget {
  final UserModel customer;

  const _CustomerDetailsDialog({required this.customer});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${customer.name} Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(colors, 'Name', customer.name),
            _buildDetailRow(colors, 'Email', customer.email),
            _buildDetailRow(colors, 'Phone', customer.phone),
            _buildDetailRow(colors, 'DOB', customer.dob),
            _buildDetailRow(colors, 'Address', customer.address ?? 'N/A'),
            _buildDetailRow(colors, 'Customer ID', customer.id ?? 'N/A'),
            _buildDetailRow(
                colors, 'Orders', (customer.orderhistory?.length ?? 0).toString()),
            _buildDetailRow(colors, 'Pending Payments',
                '₹${(customer.pendingpayments ?? 0).toStringAsFixed(2)}'),
            _buildDetailRow(colors, 'Joined',
                '${customer.created_at.day}/${customer.created_at.month}/${customer.created_at.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(AppThemeColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
