import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/add_hotel_dialogue.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/Views/admin/vendors/widgets/add_ventor_dialogue.dart';
import 'package:naivedhya/Views/admin/vendors/widgets/custom_error_widget.dart';
import 'package:naivedhya/Views/admin/vendors/widgets/loading_widget.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:naivedhya/providers/hotel_provider_for_ventor.dart';
import 'package:naivedhya/services/ventor_Service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  // Map to store vendors for each Restaurant
  final Map<String, List<Vendor>> _vendorsCache = {};
  final Map<String, bool> _isLoadingVendors = {};
  final Map<String, String?> _vendorErrors = {};

  @override
  void initState() {
    super.initState();
    // Load Restaurants for current user when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorRestaurantProvider>().loadRestaurantsForCurrentUser();
    });
  }

  // Fetch vendors for a specific Restaurant
  Future<void> _loadVendorsForRestaurant(String RestaurantId) async {
    if (_vendorsCache.containsKey(RestaurantId) || _isLoadingVendors[RestaurantId] == true) return;

    // Use addPostFrameCallback to ensure setState is called after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoadingVendors[RestaurantId] = true;
          _vendorErrors[RestaurantId] = null;
        });
      }
    });

    try {
      final vendorService = VendorService();
      final vendors = await vendorService.getVendorsByRestaurant(RestaurantId);
      
      if (mounted) {
        setState(() {
          _vendorsCache[RestaurantId] = vendors;
          _isLoadingVendors[RestaurantId] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vendorErrors[RestaurantId] = e.toString();
          _isLoadingVendors[RestaurantId] = false;
        });
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
          _buildHeader(isDesktop),
          const SizedBox(height: 24),
          _buildActionButtons(context),
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

  Widget _buildHeader(bool isDesktop) {
    return Text(
      'Restaurant & Vendors Management',
      style: TextStyle(
        fontSize: isDesktop ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, RestaurantProvider, child) {
        return Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddRestaurantDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 100, 47, 1),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.restaurant),
              label: const Text('Add New Restaurant'),
            ),
            const SizedBox(width: 12),
            if (RestaurantProvider.restaurants.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _showAddVendorDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Vendor'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Consumer<VendorRestaurantProvider>(
      builder: (context, vendorRestaurantProvider, child) {
        if (vendorRestaurantProvider.isLoading) {
          return const LoadingWidget();
        }

        if (vendorRestaurantProvider.error != null) {
          return CustomErrorWidget(
            message: vendorRestaurantProvider.error!,
            onRetry: () => vendorRestaurantProvider.loadRestaurantsForCurrentUser(),
          );
        }

        if (vendorRestaurantProvider.restaurants.isEmpty) {
          return _buildEmptyState();
        }

        return _buildRestaurantsList(vendorRestaurantProvider.restaurants, isDesktop);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Restaurants Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first Restaurant to start managing vendors',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddRestaurantDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(255, 100, 47, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Restaurant'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsList(List<Restaurant> Restaurants, bool isDesktop) {
    return ListView.builder(
      itemCount: Restaurants.length,
      itemBuilder: (context, index) {
        final Restaurant = Restaurants[index];
        // Schedule vendor loading after the current build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadVendorsForRestaurant(Restaurant.id!);
        });
        return _buildRestaurantCard(Restaurant, isDesktop);
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant Restaurant, bool isDesktop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO(255, 100, 47, 1),
          child: const Icon(
            Icons.restaurant,
            color: Colors.white,
          ),
        ),
        title: Text(
          Restaurant.name,
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
              Restaurant.address,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Admin: ${Restaurant.adminEmail ?? 'Not assigned'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRestaurantAction(value, Restaurant),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit Restaurant'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'add_vendor',
              child: ListTile(
                leading: Icon(Icons.person_add, size: 20),
                title: Text('Add Vendor'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, size: 20, color: Colors.red),
                title: Text('Delete Restaurant', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantDetails(Restaurant),
                const SizedBox(height: 16),
                _buildVendorsList(Restaurant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantDetails(Restaurant Restaurant) {
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
            'Restaurant Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Restaurant ID', Restaurant.id ?? 'N/A'),
          _buildDetailRow('Created', _formatDate(Restaurant.createdAt)),
          _buildDetailRow('Last Updated', _formatDate(Restaurant.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsList(Restaurant restaurant) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: AppTheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vendors',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddVendorDialog(context, restaurant),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Vendor'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingVendors[restaurant.id] == true
              ? const LoadingWidget()
              : _vendorErrors[restaurant.id] != null
                  ? CustomErrorWidget(
                      message: _vendorErrors[restaurant.id]!,
                      onRetry: () => _loadVendorsForRestaurant(restaurant.id!),
                    )
                  : _vendorsCache[restaurant.id]?.isEmpty ?? true
                      ? const Text(
                          'No vendors found for this Restaurant.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : Column(
                          children: _vendorsCache[restaurant.id]!
                              .map((vendor) => _buildVendorItem(vendor))
                              .toList(),
                        ),
        ],
      ),
    );
  }

  Widget _buildVendorItem(Vendor vendor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Color.fromRGBO(255, 100, 47, 1),
            child: Text(
              vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  vendor.email.isNotEmpty ? vendor.email : 'No email provided',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditVendorDialog(context, vendor),
            icon: const Icon(Icons.edit, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleRestaurantAction(String action, Restaurant Restaurant) {
    switch (action) {
      case 'edit':
        _showEditRestaurantDialog(context, Restaurant);
        break;
      case 'add_vendor':
        _showAddVendorDialog(context, Restaurant);
        break;
      case 'delete':
        _showDeleteConfirmation(context, Restaurant);
        break;
    }
  }

  void _showAddRestaurantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRestaurantDialog(),
    );
  }

  void _showEditRestaurantDialog(BuildContext context, Restaurant Restaurant) {
    showDialog(
      context: context,
      builder: (context) => AddRestaurantDialog(restaurant: Restaurant),
    );
  }

  void _showAddVendorDialog(BuildContext context, [Restaurant? Restaurant]) {
    showDialog(
      context: context,
      builder: (context) => AddVendorDialog(restaurant: Restaurant),
    );
  }

  void _showEditVendorDialog(BuildContext context, Vendor vendor) {
    showDialog(
      context: context,
      builder: (context) => AddVendorDialog(vendor: vendor),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Restaurant Restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Are you sure you want to delete "${Restaurant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RestaurantProvider>().deleteRestaurant(Restaurant.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}