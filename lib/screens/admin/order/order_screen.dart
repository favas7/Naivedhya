// screens/orders_screen.dart (Updated with proper error handling)
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/screens/admin/order/widget/loading_error.dart';
import 'package:naivedhya/screens/admin/order/widget/order_desktop_table.dart';
import 'package:naivedhya/screens/admin/order/widget/order_details.dart';
import 'package:naivedhya/screens/admin/order/widget/order_filter.dart';
import 'package:naivedhya/screens/admin/order/widget/order_mobile_list.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Load orders when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      if (orderProvider.orders.isEmpty) {
        orderProvider.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<OrderProvider>().setSearchQuery(_searchController.text);
  }

  void _onStatusChanged(String status) {
    context.read<OrderProvider>().setSelectedStatus(status);
  }

  void _onRefresh() {
    context.read<OrderProvider>().refreshOrders();
  }

  void _showOrderDetails(order) {
    OrderDetailsDialog.show(context, order);
  }

  void _editOrder(order) {
    // TODO: Implement order editing functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order editing functionality will be implemented here'),
        ),
      );
    }
  }

  Future<void> _assignDeliveryPersonnel(String orderId, String deliveryPersonId) async {
    try {
      await context.read<OrderProvider>().assignDeliveryPersonnel(orderId, deliveryPersonId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery person assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign delivery person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unassignDeliveryPersonnel(String orderId) async {
    try {
      await context.read<OrderProvider>().unassignDeliveryPersonnel(orderId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery person unassigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unassign delivery person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Orders Management',
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Quick stats or actions could be added here
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Consumer<OrderProvider>(
                  builder: (context, orderProvider, child) {
                    return Text(
                      '${orderProvider.filteredOrders.length} orders',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Consumer<OrderProvider>(
                      builder: (context, orderProvider, child) {
                        return OrderFiltersWidget(
                          searchController: _searchController,
                          selectedStatus: orderProvider.selectedStatus,
                          statusOptions: orderProvider.statusOptions,
                          onStatusChanged: _onStatusChanged,
                          onRefresh: _onRefresh,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer<OrderProvider>(
                        builder: (context, orderProvider, child) {
                          // Show error if exists
                          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
                            return ErrorWidget(
                              error: orderProvider.error!,
                              onRetry: _onRefresh,
                            );
                          }

                          // Show loading state for initial load
                          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                            return const LoadingWidget(
                              message: 'Loading orders...',
                            );
                          }

                          // Show orders list or empty state
                          return _buildOrdersList(orderProvider, isDesktop);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider, bool isDesktop) {
    // Show error banner if there's an error but we have existing data
    final hasError = orderProvider.error != null;
    final filteredOrders = orderProvider.filteredOrders;

    if (filteredOrders.isEmpty && !orderProvider.isLoading) {
      return const EmptyStateWidget(
        title: 'No orders found',
        subtitle: 'Try adjusting your search or filters',
        icon: Icons.receipt_long_outlined,
      );
    }

    return Column(
      children: [
        // Error banner
        if (hasError && filteredOrders.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ErrorWidget(
              error: orderProvider.error!,
              onRetry: _onRefresh,
            ),
          ),
        
        // Orders list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: isDesktop
                  ? OrderDesktopTable(
                      orders: filteredOrders,
                      onViewDetails: _showOrderDetails,
                      onEditOrder: _editOrder,
                      onAssignDelivery: _assignDeliveryPersonnel,
                      onUnassignDelivery: _unassignDeliveryPersonnel,
                    )
                  : OrderMobileList(
                      orders: filteredOrders,
                      onViewDetails: _showOrderDetails,
                      onEditOrder: _editOrder,
                      onAssignDelivery: _assignDeliveryPersonnel,
                      onUnassignDelivery: _unassignDeliveryPersonnel,
                    ),
            ),
          ),
        ),
        
        // Load more button
        if (orderProvider.hasMore || orderProvider.isLoadingMore)
          LoadMoreButton(
            isLoading: orderProvider.isLoadingMore,
            onPressed: () => orderProvider.loadOrders(loadMore: true),
          ),
      ],
    );
  }
}