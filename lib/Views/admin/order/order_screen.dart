// screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/add_order_screen.dart';
import 'package:naivedhya/Views/admin/order/edit_order/edit_order_screen.dart';
import 'package:naivedhya/Views/admin/order/widget/order_detail_dialog.dart';
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

  

Map<String, dynamic>? _parseVendor(dynamic vendorData) {
  if (vendorData == null) return null;
  if (vendorData is Map<String, dynamic>) return vendorData;
  
  // If it's a Vendor object, try to convert it
  try {
    if (vendorData is Vendor) {
      return {
        'id': vendorData.id,
        'name': vendorData.name ,
        'email': vendorData.email,
        'phone': vendorData.phone,
      };
    }
  } catch (e) {
    print('Error parsing vendor: $e');
  }
  
  return null;
}

// Also add debug logging to initState
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
    print('📍 [OrdersScreen] Calling OrderProvider.initialize(useEnrichedData: true)');
    
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
      appBar: AppBar(
        title: Text('Orders Management'),
        backgroundColor: themeColors.surface,
        elevation: 1,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddOrderScreen(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Cards Section
            _buildStatsSection(themeColors),

            // Search and Filter Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by order ID, customer name, hotel...',
                      prefixIcon: Icon(Icons.search, color: themeColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 12),

                  // Filter Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'All',
                                isSelected: context.watch<OrderProvider>().selectedStatusFilter == null,
                                onTap: () => context.read<OrderProvider>().setStatusFilter(null),
                                themeColors: themeColors,
                              ),
                              _buildFilterChip(
                                label: 'Pending',
                                isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'pending',
                                onTap: () => context.read<OrderProvider>().setStatusFilter('pending'),
                                themeColors: themeColors,
                              ),
                              _buildFilterChip(
                                label: 'Confirmed',
                                isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'confirmed',
                                onTap: () => context.read<OrderProvider>().setStatusFilter('confirmed'),
                                themeColors: themeColors,
                              ),
                              _buildFilterChip(
                                label: 'Preparing',
                                isSelected: context.watch<OrderProvider>().selectedStatusFilter == 'preparing',
                                onTap: () => context.read<OrderProvider>().setStatusFilter('preparing'),
                                themeColors: themeColors,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
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
            ),

            // Orders List Section
            _buildOrdersListSection(themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(AppThemeColors themeColors) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orders Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => context.read<OrderProvider>().refreshOrders(),
                  ),
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      // TODO: Implement export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Manage and track all orders across your enterprise',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          // Stats Cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Total Orders', '1,247', 'Today', themeColors),
                _buildStatCard('Pending', '23', 'Urgent', themeColors,
                    badgeColor: AppTheme.warning),
                _buildStatCard('In Transit', '45', 'Active', themeColors,
                    badgeColor: AppTheme.info),
                _buildStatCard('Delivered', '1,179', 'Completed', themeColors,
                    badgeColor: AppTheme.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String badge, AppThemeColors themeColors,
      {Color badgeColor = AppTheme.primary}) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColors.background.withAlpha(50)),
      ),
      constraints: BoxConstraints(minWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap,
      required AppThemeColors themeColors}) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: themeColors.surface,
        selectedColor: AppTheme.primary.withAlpha(200),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : themeColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : themeColors.background.withAlpha(50),
        ),
      ),
    );
  }

// screens/orders_screen.dart - WITH DEBUG LOGGING
// Add these debug prints to your existing _buildOrdersListSection method

Widget _buildOrdersListSection(AppThemeColors themeColors) {
  return Consumer<OrderProvider>(
    builder: (context, orderProvider, child) {
      print('\n🎨 [OrdersScreen] Building orders list section');
      print('📊 [OrdersScreen] State:');
      print('   - Orders with Details: ${orderProvider.ordersWithDetails.length}');
      print('   - Is Loading: ${orderProvider.isLoading}');
      print('   - Error Message: ${orderProvider.errorMessage}');
      print('   - Has More Pages: ${orderProvider.hasMorePages}');
      
      // Check if there's an error
      if (orderProvider.errorMessage != null) {
        print('❌ [OrdersScreen] ERROR STATE: ${orderProvider.errorMessage}');
        return Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                SizedBox(height: 16),
                Text(
                  'Error Loading Orders',
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  orderProvider.errorMessage ?? 'Unknown error',
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    print('🔄 [OrdersScreen] Retry button pressed');
                    orderProvider.refreshOrders();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
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
        print('ℹ️ [OrdersScreen] EMPTY STATE: No orders to display');
        return Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: themeColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(
                    color: themeColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
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

      print('✅ [OrdersScreen] Rendering ${orderProvider.ordersWithDetails.length} orders');
      
      return Container(
        color: themeColors.background,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '${orderProvider.ordersWithDetails.length} Orders',
                style: TextStyle(
                  color: themeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 12),
            ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: orderProvider.ordersWithDetails.length + (orderProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == orderProvider.ordersWithDetails.length) {
                  print('⏳ [OrdersScreen] Showing loading indicator at end of list');
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final orderData = orderProvider.ordersWithDetails[index];
                
                print('\n📦 [OrdersScreen] Building order card #$index');
                print('   - Order Data Keys: ${orderData.keys.join(", ")}');
                
                // Extract data with null safety
                final order = orderData['order'] as Order?;
                final restaurant = orderData['restaurant'] as Map<String, dynamic>?;
                final vendor = _parseVendor(orderData['vendor']);
                final orderItems = orderData['orderItems'] as List? ?? [];

                if (order == null) {
                  print('⚠️ [OrdersScreen] Order is NULL at index $index!');
                  return SizedBox.shrink();
                }
                
                print('   - Order: ${order.orderNumber}');
                print('   - Restaurant: ${restaurant?['name'] ?? 'null'}');
                print('   - Vendor: ${vendor?['name'] ?? 'null'}');
                print('   - Items: ${orderItems.length}');

                return _buildOrderCard(
                  order: order,
                  restaurant: restaurant,
                  vendor: vendor,
                  orderItems: orderItems,
                  themeColors: themeColors,
                  onTap: () {
                    print('👆 [OrdersScreen] Order card tapped: ${order.orderNumber}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildOrderCard({
    required Order order,
    required Map<String, dynamic>? restaurant,
    required Map<String, dynamic>? vendor,
    required List orderItems,
    required AppThemeColors themeColors,
    required VoidCallback onTap,
  }) {
    final statusColor = themeColors.getOrderStatusColor(order.status);
    final statusBgColor = themeColors.getOrderStatusBgColor(order.status);
    final itemsDisplay = orderItems.isNotEmpty
        ? (orderItems).map((item) => item.itemName ?? 'Item').join(', ')
        : 'No items';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeColors.background.withAlpha(50)),
        ),
        child: Column(
          children: [
            // Header Row with Order ID, Amount, Status
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showOrderMenu(context, order, themeColors),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: themeColors.background.withAlpha(30)),

            // Customer Info Row
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: themeColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? 'Unknown Customer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: themeColors.textPrimary,
                          ),
                        ),
                        Text(
                          '+91 XXXXXX XXXX',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.schedule, size: 16, color: themeColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    _formatTime(order.createdAt ?? DateTime.now())
                    ,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Restaurant and Location Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      restaurant?['name'] ?? 'Unknown Restaurant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: themeColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant?['city'] ?? 'Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Vendor Info
            if (vendor != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.store, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vendor['name'] ?? 'Unknown Vendor',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Items Display
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 16, color: themeColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items: $itemsDisplay',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Info and ETA
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, size: 16, color: AppTheme.success),
                      SizedBox(width: 4),
                      Text(
                        'Delivery Agent: TBD',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: themeColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'ETA: 15 mins',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              padding: EdgeInsets.all(16),
              child: Text(
                'Order Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeColors.textPrimary,
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primary),
              title: Text('Edit Order'),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => EditOrderScreen(orderId: order.orderId
                  ),
                )
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: AppTheme.info),
              title: Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.error),
              title: Text('Cancel Order'),
              onTap: () {
                Navigator.pop(context);
                _showCancelDialog(context, order);
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderProvider>().updateOrderStatus(order.orderId, 'cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order cancelled successfully')),
              );
            },
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}