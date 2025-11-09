// screens/orders_screen.dart - REFACTORED WITH GRID/LIST VIEW
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/add_order_screen.dart';
import 'package:naivedhya/Views/admin/order/edit_order/edit_order_screen.dart';
import 'package:naivedhya/Views/admin/order/order_detail_dialog.dart';
import 'package:naivedhya/Views/admin/order/widget/order_card.dart';
import 'package:naivedhya/Views/admin/order/widget/order_filter_chip.dart';
import 'package:naivedhya/Views/admin/order/widget/order_search_bar.dart';
import 'package:naivedhya/Views/admin/order/widget/order_stats_card.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/providers/order_provider.dart';
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
  bool _isGridView = true; // Toggle between grid and list

  Map<String, dynamic>? _parseVendor(dynamic vendorData) {
    if (vendorData == null) return null;
    if (vendorData is Map<String, dynamic>) return vendorData;

    // If it's a Vendor object, try to convert it
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

    print('📱 [OrdersScreen] Setting up post-frame callback for initialization');

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 [OrdersScreen] Post-frame callback executing...');
      print(
          '📍 [OrdersScreen] Calling OrderProvider.initialize(useEnrichedData: true)');

      try {
        context.read<OrderProvider>().initialize(useEnrichedData: true);
        print('✅ [OrdersScreen] Initialize call completed');
      } catch (e) {
        print('❌ [OrdersScreen] ERROR in initialize: $e');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
                  // Stats Cards Section
                  _buildStatsSection(themeColors),

                  // Search and Filter Section
                  _buildSearchAndFilters(themeColors),

                  // Orders List Section
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
                  'Manage and track all orders across your enterprise',
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
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color:
                        _isGridView ? themeColors.primary : themeColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isGridView = true),
                  tooltip: 'Grid View',
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color:
                        !_isGridView ? themeColors.primary : themeColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isGridView = false),
                  tooltip: 'List View',
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
                onPressed: () =>
                    context.read<OrderProvider>().refreshOrders(),
                tooltip: 'Refresh Orders',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Export feature coming soon')),
                  );
                },
                tooltip: 'Export',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddOrderScreen(),
                    ),
                  );
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

  Widget _buildStatsSection(AppThemeColors themeColors) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Calculate dynamic stats from orders
        final totalOrders = orderProvider.ordersWithDetails.length;
        final pendingOrders = orderProvider.ordersWithDetails
            .where((od) => (od['order'] as Order).status == 'pending')
            .length;
        final inTransitOrders = orderProvider.ordersWithDetails
            .where((od) =>
                ['confirmed', 'preparing', 'ready'].contains(
                    (od['order'] as Order).status))
            .length;
        final deliveredOrders = orderProvider.ordersWithDetails
            .where((od) => (od['order'] as Order).status == 'delivered')
            .length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OrderStatsCard(
                  title: 'Total Orders',
                  value: totalOrders.toString(),
                  badge: 'All Time',
                  badgeColor: AppTheme.primary,
                  themeColors: themeColors,
                ),
                OrderStatsCard(
                  title: 'Pending',
                  value: pendingOrders.toString(),
                  badge: 'Urgent',
                  badgeColor: AppTheme.warning,
                  themeColors: themeColors,
                ),
                OrderStatsCard(
                  title: 'In Transit',
                  value: inTransitOrders.toString(),
                  badge: 'Active',
                  badgeColor: AppTheme.info,
                  themeColors: themeColors,
                ),
                OrderStatsCard(
                  title: 'Delivered',
                  value: deliveredOrders.toString(),
                  badge: 'Completed',
                  badgeColor: AppTheme.success,
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
        children: [
          // Search Bar
          OrderSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            themeColors: themeColors,
          ),
          const SizedBox(height: 12),

          // Filter Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OrderFilterChip(
                        label: 'All',
                        isSelected: context
                                .watch<OrderProvider>()
                                .selectedStatusFilter ==
                            null,
                        onTap: () => context
                            .read<OrderProvider>()
                            .setStatusFilter(null),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Pending',
                        isSelected: context
                                .watch<OrderProvider>()
                                .selectedStatusFilter ==
                            'pending',
                        onTap: () => context
                            .read<OrderProvider>()
                            .setStatusFilter('pending'),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Confirmed',
                        isSelected: context
                                .watch<OrderProvider>()
                                .selectedStatusFilter ==
                            'confirmed',
                        onTap: () => context
                            .read<OrderProvider>()
                            .setStatusFilter('confirmed'),
                        themeColors: themeColors,
                      ),
                      OrderFilterChip(
                        label: 'Preparing',
                        isSelected: context
                                .watch<OrderProvider>()
                                .selectedStatusFilter ==
                            'preparing',
                        onTap: () => context
                            .read<OrderProvider>()
                            .setStatusFilter('preparing'),
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
        print('\n🎨 [OrdersScreen] Building orders list section');
        print('📊 [OrdersScreen] State:');
        print(
            '   - Orders with Details: ${orderProvider.ordersWithDetails.length}');
        print('   - Is Loading: ${orderProvider.isLoading}');
        print('   - Error Message: ${orderProvider.errorMessage}');
        print('   - Has More Pages: ${orderProvider.hasMorePages}');

        // Check if there's an error
        if (orderProvider.errorMessage != null) {
          print(
              '❌ [OrdersScreen] ERROR STATE: ${orderProvider.errorMessage}');
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: AppTheme.error),
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
                    onPressed: () {
                      print('🔄 [OrdersScreen] Retry button pressed');
                      orderProvider.refreshOrders();
                    },
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

        if (orderProvider.ordersWithDetails.isEmpty &&
            !orderProvider.isLoading) {
          print('ℹ️ [OrdersScreen] EMPTY STATE: No orders to display');
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: themeColors.textSecondary),
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

        print(
            '✅ [OrdersScreen] Rendering ${orderProvider.ordersWithDetails.length} orders');

        return Container(
          color: themeColors.background,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '${orderProvider.ordersWithDetails.length} Orders',
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isGridView
                  ? _buildGridView(orderProvider, themeColors)
                  : _buildListView(orderProvider, themeColors),
              
              // Loading indicator for pagination
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

  Widget _buildGridView(
      OrderProvider orderProvider, AppThemeColors themeColors) {
    print('🎨 [OrdersScreen] Building GRID view');
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.0,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 320, // Slightly taller than vendor cards to fit all info
      ),
      itemCount: orderProvider.ordersWithDetails.length,
      itemBuilder: (context, index) {
        final orderData = orderProvider.ordersWithDetails[index];

        print('\n📦 [OrdersScreen] Building grid order card #$index');
        print('   - Order Data Keys: ${orderData.keys.join(", ")}');

        // Extract data with null safety
        final order = orderData['order'] as Order?;
        final restaurant = orderData['restaurant'] as Map<String, dynamic>?;
        final vendor = _parseVendor(orderData['vendor']);
        final orderItems = orderData['orderItems'] as List? ?? [];

        if (order == null) {
          print('⚠️ [OrdersScreen] Order is NULL at index $index!');
          return const SizedBox.shrink();
        }

        print('   - Order: ${order.orderNumber}');
        print('   - Restaurant: ${restaurant?['name'] ?? 'null'}');
        print('   - Vendor: ${vendor?['name'] ?? 'null'}');
        print('   - Items: ${orderItems.length}');

        return OrderCard(
          order: order,
          restaurant: restaurant,
          vendor: vendor,
          orderItems: orderItems,
          themeColors: themeColors,
          onTap: () {
            print(
                '👆 [OrdersScreen] Order card tapped: ${order.orderNumber}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          onShowMenu: _showOrderMenu,
        );
      },
    );
  }

  Widget _buildListView(
      OrderProvider orderProvider, AppThemeColors themeColors) {
    print('🎨 [OrdersScreen] Building LIST view');
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orderProvider.ordersWithDetails.length,
      itemBuilder: (context, index) {
        final orderData = orderProvider.ordersWithDetails[index];

        print('\n📦 [OrdersScreen] Building list order card #$index');
        print('   - Order Data Keys: ${orderData.keys.join(", ")}');

        // Extract data with null safety
        final order = orderData['order'] as Order?;
        final restaurant = orderData['restaurant'] as Map<String, dynamic>?;
        final vendor = _parseVendor(orderData['vendor']);
        final orderItems = orderData['orderItems'] as List? ?? [];

        if (order == null) {
          print('⚠️ [OrdersScreen] Order is NULL at index $index!');
          return const SizedBox.shrink();
        }

        print('   - Order: ${order.orderNumber}');
        print('   - Restaurant: ${restaurant?['name'] ?? 'null'}');
        print('   - Vendor: ${vendor?['name'] ?? 'null'}');
        print('   - Items: ${orderItems.length}');

        return OrderCard(
          order: order,
          restaurant: restaurant,
          vendor: vendor,
          orderItems: orderItems,
          themeColors: themeColors,
          onTap: () {
            print(
                '👆 [OrdersScreen] Order card tapped: ${order.orderNumber}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          onShowMenu: _showOrderMenu,
        );
      },
    );
  }

  void _showOrderMenu(
      BuildContext context, Order order, AppThemeColors themeColors) {
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
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primary),
              title: const Text('Edit Order'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditOrderScreen(orderId: order.orderId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: AppTheme.info),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Message feature coming soon')),
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
              context
                  .read<OrderProvider>()
                  .updateOrderStatus(order.orderId, 'cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Order cancelled successfully')),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}