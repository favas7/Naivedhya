import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/add_order_screen.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize orders on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().initialize();
    });

    // Infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<OrderProvider>().loadNextPage();
    }
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    if (_searchQuery.isEmpty) return orders;

    return orders.where((order) {
      return order.orderId.toString().contains(_searchQuery) ||
          order.orderNumber.toString().contains(_searchQuery) ||
          (order.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDesktop, context),
          const SizedBox(height: 24),
          _buildActionBar(isDesktop, context),
          const SizedBox(height: 16),
          _buildSearchAndFilter(isDesktop, context),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(context, isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Orders Management',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Consumer<OrderProvider>(
          builder: (context, provider, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 100, 47, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total: ${provider.orders.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionBar(bool isDesktop, BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const
            AddOrderScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 100, 47, 1),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 12,
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Create Order'),
        ),
        ElevatedButton.icon(
          onPressed: () => context.read<OrderProvider>().refreshOrders(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 12,
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(bool isDesktop, BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Search Bar
        SizedBox(
          width: isDesktop ? 400 : double.infinity,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search by order ID, order number or customer name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // Status Filter
        _buildStatusFilterBar(context),
      ],
    );
  }

  Widget _buildStatusFilterBar(BuildContext context) {
    final statusOptions = [
      'All',
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked_up',
      'delivering',
      'completed',
      'cancelled',
    ];

    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statusOptions
                .map((status) {
                  final isSelected = status == 'All'
                      ? provider.selectedStatusFilter == null
                      : status == provider.selectedStatusFilter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: Color.fromRGBO(255, 100, 47, 1),
                      side: BorderSide(
                        color: isSelected
                            ? Color.fromRGBO(255, 100, 47, 1)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          provider.setStatusFilter(
                            status == 'All' ? null : status,
                          );
                        }
                      },
                    ),
                  );
                })
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // Initial loading
        if (provider.orders.isEmpty && provider.isLoading) {
          return _buildLoadingState();
        }

        // Error state
        if (provider.errorMessage != null && provider.orders.isEmpty) {
          return _buildErrorState(context, provider);
        }

        // Empty state
        if (provider.isEmpty) {
          return _buildEmptyState(context);
        }

        final filteredOrders = _getFilteredOrders(provider.orders);

        // No search results
        if (filteredOrders.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoResultsState(context);
        }

        return _buildOrdersList(context, filteredOrders, provider, isDesktop);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OrderProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              provider.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refreshOrders(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first order to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateOrderDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(255, 100, 47, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Match Your Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<Order> orders,
    OrderProvider provider,
    bool isDesktop,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: orders.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at end
        if (index == orders.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final order = orders[index];
        return _buildOrderCard(context, order, isDesktop, provider);
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Order order,
    bool isDesktop,
    OrderProvider provider,
  ) {
    final statusColor = _getStatusColor(order.status);
    final statusBgColor = statusColor.withAlpha(80);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusBgColor,
          child: Text(
            '#${order.orderId.toString().substring(0, 3)}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        title: Text(
          order.customerName ?? 'Guest Customer',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Order #${order.orderId}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '₹${order.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetailsSection(order),
                const SizedBox(height: 16),
                _buildActionButtons(context, order, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Order ID', order.orderId),
          _buildDetailRow('Order Number', order.orderNumber),
          _buildDetailRow('Customer', order.customerName ?? 'N/A'),
          _buildDetailRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
          _buildDetailRow('Status', order.status.toUpperCase()),
          _buildDetailRow('Restaurant ID', order.restaurantId),
          _buildDetailRow('Vendor ID', order.vendorId),
          if (order.deliveryStatus != null)
            _buildDetailRow('Delivery Status', order.deliveryStatus!),
          if (order.deliveryPersonId != null)
            _buildDetailRow('Delivery Person', order.deliveryPersonId!),
          _buildDetailRow('Proposed Delivery', _formatDate(order.proposedDeliveryTime)),
          if (order.pickupTime != null)
            _buildDetailRow('Pickup Time', _formatDate(order.pickupTime)),
          if (order.deliveryTime != null)
            _buildDetailRow('Delivery Time', _formatDate(order.deliveryTime)),
          _buildDetailRow('Created', _formatDate(order.createdAt)),
          _buildDetailRow('Updated', _formatDate(order.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Order order,
    OrderProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showOrderDetailsDialog(context, order),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showStatusUpdateDialog(context, order, provider),
            icon: const Icon(Icons.update, size: 16),
            label: const Text('Status'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteConfirmation(context, order, provider),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.blue;
      case 'delivering':
        return Colors.cyan;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Dialog Methods
  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Order'),
        content: const Text('Create Order functionality will be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Order ID', order.orderId),
              _buildDetailRow('Customer', order.customerName ?? 'N/A'),
              _buildDetailRow('Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Status', order.status.toUpperCase()),
              _buildDetailRow('Restaurant', order.restaurantId),
              _buildDetailRow('Vendor', order.vendorId),
              if (order.deliveryStatus != null)
                _buildDetailRow('Delivery Status', order.deliveryStatus!),
              if (order.deliveryPersonId != null)
                _buildDetailRow('Delivery Person', order.deliveryPersonId!),
              _buildDetailRow('Proposed Delivery', _formatDate(order.proposedDeliveryTime)),
              if (order.pickupTime != null)
                _buildDetailRow('Pickup Time', _formatDate(order.pickupTime)),
              if (order.deliveryTime != null)
                _buildDetailRow('Delivery Time', _formatDate(order.deliveryTime)),
              _buildDetailRow('Created', _formatDate(order.createdAt)),
            ],
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

  void _showStatusUpdateDialog(
    BuildContext context,
    Order order,
    OrderProvider provider,
  ) {
    final statusOptions = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked_up',
      'delivering',
      'completed',
      'cancelled',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions
                .map(
                  (status) => RadioListTile<String>(
                    title: Text(status.toUpperCase()),
                    value: status,
                    groupValue: order.status.toLowerCase(),
                    onChanged: (value) async {
                      if (value != null) {
                        Navigator.pop(context);
                        await provider.updateOrderStatus(order.orderId, value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order status updated to ${value.toUpperCase()}',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Order order,
    OrderProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to delete order #${order.orderId}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteOrder(order.orderId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Order deleted successfully'
                          : 'Failed to delete order',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}