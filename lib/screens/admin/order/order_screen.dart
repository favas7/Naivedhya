// screens/orders_screen.dart
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
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order editing functionality will be implemented here'),
      ),
    );
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
          Text(
            'Orders Management',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                          if (orderProvider.error != null) {
                            return Column(
                              children: [
                                ErrorWidget(
                                  error: orderProvider.error!,
                                  onRetry: _onRefresh,
                                ),
                                if (!orderProvider.isLoading)
                                  Expanded(
                                    child: _buildOrdersList(orderProvider, isDesktop),
                                  ),
                              ],
                            );
                          }

                          // Show loading state
                          if (orderProvider.isLoading) {
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
    if (orderProvider.filteredOrders.isEmpty) {
      return const EmptyStateWidget(
        title: 'No orders found',
        subtitle: 'Try adjusting your search or filters',
      );
    }

    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: isDesktop
                ? OrderDesktopTable(
                    orders: orderProvider.filteredOrders,
                    onViewDetails: _showOrderDetails,
                    onEditOrder: _editOrder,
                  )
                : OrderMobileList(
                    orders: orderProvider.filteredOrders,
                    onViewDetails: _showOrderDetails,
                    onEditOrder: _editOrder,
                  ),
          ),
        ),
        if (orderProvider.hasMore || orderProvider.isLoadingMore)
          LoadMoreButton(
            isLoading: orderProvider.isLoadingMore,
            onPressed: () => orderProvider.loadOrders(loadMore: true),
          ),
      ],
    );
  }
}