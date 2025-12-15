// screens/orders_screen.dart - WITH ORDER TYPE FILTERS
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/widget/assign_delivery_partner_dialog.dart';
import 'package:naivedhya/Views/admin/order/widget/order_card.dart';
import 'package:naivedhya/Views/admin/order/widget/order_list_item.dart';
import 'package:naivedhya/Views/admin/order/widget/compact_stats_card.dart';
import 'package:naivedhya/Views/admin/order/widget/order_filter_chip.dart';
import 'package:naivedhya/Views/admin/order/widget/order_search_bar.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/services/toast_notification_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  bool _isGridView = false;

  Map<String, dynamic>? _parseVendor(dynamic vendorData) {
    if (vendorData == null) return null;
    if (vendorData is Map<String, dynamic>) return vendorData;

    try {
      if (vendorData is Vendor) {
        return {
          'id': vendorData.id,
          'name': vendorData.name,
          'email': vendorData.email,
          'phone': vendorData.phone,
        };
      }
    } catch (e) {
      print('Error parsing vendor: $e');
    }

    return null;
  }

    @override
    void initState() {
      super.initState();
      print('\n🎬 [OrdersScreen] initState called');

      _scrollController = ScrollController();
      _scrollController.addListener(_onScroll);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Initialize toast
        ToastNotificationService.init(context);
        
        // Initialize orders
        context.read<OrderProvider>().initialize(useEnrichedData: true);
        
        // Subscribe to real-time updates
        context.read<OrderProvider>().subscribeToOrderUpdates();
        
        // Set callback for new orders
        context.read<OrderProvider>().setNewOrderCallback((orderData) {
          print('🔔 [OrdersScreen] New order callback triggered!');
          
          // Show toast notification
          ToastNotificationService.showNewOrderNotification(
            orderNumber: orderData['order_number']?.toString() ?? 'Unknown',
            orderType: orderData['order_type'] ?? 'Order',
            totalAmount: (orderData['total_amount'] as num?)?.toDouble() ?? 0.0,
            customerName: orderData['customer_name'] ?? 'Customer',
            onTap: () {
              print('🔔 [OrdersScreen] Toast tapped - refreshing orders');
              // Optional: Navigate to delivery filter
              // context.read<OrderProvider>().setOrderTypeFilter('Delivery');
            },
          );
        });
      });
    }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    context.read<OrderProvider>().unsubscribeFromOrderUpdates(); // Add this line
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<OrderProvider>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: themeColors.background,
      body: Column(
        children: [
          _buildHeader(themeColors),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildCompactStatsSection(themeColors),
                  _buildSearchAndFilters(themeColors),
                  _buildOrdersListSection(themeColors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track and manage all orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // View Toggle
          Container(
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeColors.isDark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color: !_isGridView ? themeColors.primary : themeColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isGridView = false),
                  tooltip: 'List View',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: themeColors.isDark
                      ? Colors.grey[700]
                      : Colors.grey[300],
                ),
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView ? themeColors.primary : themeColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isGridView = true),
                  tooltip: 'Grid View',
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<OrderProvider>().refreshOrders(),
                tooltip: 'Refresh Orders',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                },
                tooltip: 'Export',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const OrderScreen(),
                  //   ),
                  // );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildCompactStatsSection(AppThemeColors themeColors) {
  return Consumer<OrderProvider>(
    builder: (context, orderProvider, child) {
      // ✅ Count from ordersWithDetails OR orders (whichever has data)
      final allOrders = orderProvider.ordersWithDetails.isNotEmpty 
          ? orderProvider.ordersWithDetails 
          : orderProvider.orders.map((o) => {'order': o}).toList();
      
      final totalOrders = allOrders.length;
      
      final pendingOrders = allOrders
          .where((od) => (od['order'] as Order).status == 'Pending')
          .length;
      
      final deliveryOrders = allOrders
          .where((od) => (od['order'] as Order).orderType == 'Delivery')
          .length;
      
      final dineInOrders = allOrders
          .where((od) => (od['order'] as Order).orderType == 'Dine In')
          .length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CompactStatsCard(
                label: 'Total Orders',
                value: totalOrders.toString(),
                icon: Icons.shopping_bag_outlined,
                color: AppTheme.primary,
                themeColors: themeColors,
              ),
              const SizedBox(width: 12),
              CompactStatsCard(
                label: 'Pending',
                value: pendingOrders.toString(),
                icon: Icons.pending_outlined,
                color: AppTheme.warning,
                themeColors: themeColors,
              ),
              const SizedBox(width: 12),
              CompactStatsCard(
                label: 'Delivery',
                value: deliveryOrders.toString(),
                icon: Icons.delivery_dining,
                color: AppTheme.warning,
                themeColors: themeColors,
              ),
              const SizedBox(width: 12),
              CompactStatsCard(
                label: 'Dine In',
                value: dineInOrders.toString(),
                icon: Icons.restaurant,
                color: AppTheme.info,
                themeColors: themeColors,
              ),
            ],
          ),
        ),
      );
    },
  );
}
  Widget _buildSearchAndFilters(AppThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          OrderSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            themeColors: themeColors,
          ),
          const SizedBox(height: 16),

          // ✅ ORDER TYPE FILTERS (PRIMARY)
          Text(
            'Order Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OrderFilterChip(
                  label: 'All Orders',
                  isSelected: context.watch<OrderProvider>().selectedOrderTypeFilter == null,
                  onTap: () => context.read<OrderProvider>().setOrderTypeFilter(null),
                  themeColors: themeColors,
                ),
                OrderFilterChip(
                  label: '🚚 Delivery',
                  isSelected: context.watch<OrderProvider>().selectedOrderTypeFilter == 'Delivery',
                  onTap: () => context.read<OrderProvider>().setOrderTypeFilter('Delivery'),
                  themeColors: themeColors,
                  color: AppTheme.warning,
                ),
                OrderFilterChip(
                  label: '🍽️ Dine In',
                  isSelected: context.watch<OrderProvider>().selectedOrderTypeFilter == 'Dine In',
                  onTap: () => context.read<OrderProvider>().setOrderTypeFilter('Dine In'),
                  themeColors: themeColors,
                ),
                OrderFilterChip(
                  label: '📦 Takeaway',
                  isSelected: context.watch<OrderProvider>().selectedOrderTypeFilter == 'Takeaway',
                  onTap: () => context.read<OrderProvider>().setOrderTypeFilter('Takeaway'),
                  themeColors: themeColors,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // STATUS FILTERS (SECONDARY)
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OrderFilterChip(
                        label: 'All',
                        isSelected: context.watch<OrderProvider>().selectedStatusFilter == null,
                        onTap: () => context.read<OrderProvider>().setStatusFilter(null),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Pending',
                        isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'Pending',
                        onTap: () => context.read<OrderProvider>().setStatusFilter('Pending'),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Confirmed',
                        isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'Confirmed',
                        onTap: () => context.read<OrderProvider>().setStatusFilter('Confirmed'),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Preparing',
                        isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'Preparing',
                        onTap: () => context.read<OrderProvider>().setStatusFilter('Preparing'),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Delivered',
                        isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'Delivered',
                        onTap: () => context.read<OrderProvider>().setStatusFilter('Delivered'),
                        themeColors: themeColors,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.filter_list, color: AppTheme.primary),
                onPressed: () {
                  // TODO: Implement advanced filters
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersListSection(AppThemeColors themeColors) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Orders',
                    style: TextStyle(
                      color: themeColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderProvider.errorMessage ?? 'Unknown error',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => orderProvider.refreshOrders(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (orderProvider.ordersWithDetails.isEmpty && !orderProvider.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: themeColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here once they are created',
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: themeColors.background,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${orderProvider.ordersWithDetails.length} Orders',
                      style: TextStyle(
                        color: themeColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (!_isGridView)
                      Text(
                        'Showing list view',
                        style: TextStyle(
                          color: themeColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              _isGridView
                  ? _buildGridView(orderProvider, themeColors)
                  : _buildCompactListView(orderProvider, themeColors),

              if (orderProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactListView(OrderProvider orderProvider, AppThemeColors themeColors) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orderProvider.ordersWithDetails.length,
      itemBuilder: (context, index) {
        final orderData = orderProvider.ordersWithDetails[index];
        final order = orderData['order'] as Order?;
        final restaurant = orderData['restaurant'] as Map<String, dynamic>?;
        final vendor = _parseVendor(orderData['vendor']);

        if (order == null) return const SizedBox.shrink();

        return OrderListItem(
          order: order,
          restaurant: restaurant,
          vendor: vendor,
          themeColors: themeColors,
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => OrderDetailScreen(order: order),
            //   ),
            // );
          },
          onShowMenu: _showOrderMenu,
        );
      },
    );
  }

  Widget _buildGridView(OrderProvider orderProvider, AppThemeColors themeColors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.0,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 320,
      ),
      itemCount: orderProvider.ordersWithDetails.length,
      itemBuilder: (context, index) {
        final orderData = orderProvider.ordersWithDetails[index];
        final order = orderData['order'] as Order?;
        final restaurant = orderData['restaurant'] as Map<String, dynamic>?;
        final vendor = _parseVendor(orderData['vendor']);
        final orderItems = orderData['orderItems'] as List? ?? [];

        if (order == null) return const SizedBox.shrink();

        return OrderCard(
          order: order,
          restaurant: restaurant,
          vendor: vendor,
          orderItems: orderItems,
          themeColors: themeColors,
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => OrderDetailScreen(order: order),
            //   ),
            // );
          },
          onShowMenu: _showOrderMenu,
        );
      },
    );
  }

  void _showOrderMenu(BuildContext context, Order order, AppThemeColors themeColors) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: themeColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Order Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeColors.textPrimary,
                ),
              ),
            ),
            const Divider(),
            
            // ✅ ADD ASSIGN DELIVERY PARTNER OPTION (ONLY FOR DELIVERY ORDERS)
            if (order.orderType == 'Delivery' && order.deliveryPersonId == null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delivery_dining, color: AppTheme.warning),
                ),
                title: const Text('Assign Delivery Partner'),
                subtitle: const Text('Select available partner'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AssignDeliveryPartnerDialog(order: order),
                  );
                },
              ),
            
            // ✅ SHOW CURRENT PARTNER IF ASSIGNED
            if (order.orderType == 'Delivery' && order.deliveryPersonId != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check_circle, color: AppTheme.success),
                ),
                title: const Text('Partner Assigned'),
                subtitle: Text('ID: ${order.deliveryPersonId}'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Show partner details or reassign option
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partner details coming soon')),
                    );
                  },
                  child: const Text('View'),
                ),
              ),
            
            // ListTile(
            //   leading: Icon(Icons.edit, color: AppTheme.primary),
            //   title: const Text('Edit Order'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => EditOrderScreen(orderId: order.orderId),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.message, color: AppTheme.info),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.error),
              title: const Text('Cancel Order'),
              onTap: () {
                Navigator.pop(context);
                _showCancelDialog(context, order);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
    void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderProvider>().updateOrderStatus(order.orderId, 'cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancelled successfully')),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}