import 'package:flutter/material.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/providers/hotel_provider_for_ventor.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_hotel_dialogue.dart';
import 'package:naivedhya/screens/admin/vendors/widgets/add_ventor_dialogue.dart';
import 'package:naivedhya/screens/admin/vendors/widgets/custom_error_widget.dart';
import 'package:naivedhya/screens/admin/vendors/widgets/loading_widget.dart';
import 'package:naivedhya/services/ventor_Service.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../../models/hotel.dart';
import '../../../providers/hotel_provider.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  // Map to store vendors for each hotel
  final Map<String, List<Vendor>> _vendorsCache = {};
  final Map<String, bool> _isLoadingVendors = {};
  final Map<String, String?> _vendorErrors = {};

  @override
  void initState() {
    super.initState();
    // Load hotels for current user when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorHotelProvider>().loadHotelsForCurrentUser();
    });
  }

  // Fetch vendors for a specific hotel
  Future<void> _loadVendorsForHotel(String hotelId) async {
    if (_vendorsCache.containsKey(hotelId) || _isLoadingVendors[hotelId] == true) return;

    // Use addPostFrameCallback to ensure setState is called after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoadingVendors[hotelId] = true;
          _vendorErrors[hotelId] = null;
        });
      }
    });

    try {
      final vendorService = VendorService();
      final vendors = await vendorService.getVendorsByHotel(hotelId);
      
      if (mounted) {
        setState(() {
          _vendorsCache[hotelId] = vendors;
          _isLoadingVendors[hotelId] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vendorErrors[hotelId] = e.toString();
          _isLoadingVendors[hotelId] = false;
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
      'Hotel & Vendors Management',
      style: TextStyle(
        fontSize: isDesktop ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<HotelProvider>(
      builder: (context, hotelProvider, child) {
        return Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddHotelDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 100, 47, 1),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.restaurant),
              label: const Text('Add New Hotel'),
            ),
            const SizedBox(width: 12),
            if (hotelProvider.hotels.isNotEmpty)
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
    return Consumer<VendorHotelProvider>(
      builder: (context, vendorHotelProvider, child) {
        if (vendorHotelProvider.isLoading) {
          return const LoadingWidget();
        }

        if (vendorHotelProvider.error != null) {
          return CustomErrorWidget(
            message: vendorHotelProvider.error!,
            onRetry: () => vendorHotelProvider.loadHotelsForCurrentUser(),
          );
        }

        if (vendorHotelProvider.hotels.isEmpty) {
          return _buildEmptyState();
        }

        return _buildHotelsList(vendorHotelProvider.hotels, isDesktop);
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
            'No Hotels Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first hotel to start managing vendors',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddHotelDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(255, 100, 47, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Hotel'),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsList(List<Hotel> hotels, bool isDesktop) {
    return ListView.builder(
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        // Schedule vendor loading after the current build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadVendorsForHotel(hotel.id!);
        });
        return _buildHotelCard(hotel, isDesktop);
      },
    );
  }

  Widget _buildHotelCard(Hotel hotel, bool isDesktop) {
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
          hotel.name,
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
              hotel.address,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Admin: ${hotel.adminEmail ?? 'Not assigned'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleHotelAction(value, hotel),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit Hotel'),
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
                title: Text('Delete Hotel', style: TextStyle(color: Colors.red)),
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
                _buildHotelDetails(hotel),
                const SizedBox(height: 16),
                _buildVendorsList(hotel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelDetails(Hotel hotel) {
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
            'Hotel Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Hotel ID', hotel.id ?? 'N/A'),
          _buildDetailRow('Created', _formatDate(hotel.createdAt)),
          _buildDetailRow('Last Updated', _formatDate(hotel.updatedAt)),
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

  Widget _buildVendorsList(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: AppColors.primary),
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
                onPressed: () => _showAddVendorDialog(context, hotel),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Vendor'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingVendors[hotel.id] == true
              ? const LoadingWidget()
              : _vendorErrors[hotel.id] != null
                  ? CustomErrorWidget(
                      message: _vendorErrors[hotel.id]!,
                      onRetry: () => _loadVendorsForHotel(hotel.id!),
                    )
                  : _vendorsCache[hotel.id]?.isEmpty ?? true
                      ? const Text(
                          'No vendors found for this hotel.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : Column(
                          children: _vendorsCache[hotel.id]!
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

  void _handleHotelAction(String action, Hotel hotel) {
    switch (action) {
      case 'edit':
        _showEditHotelDialog(context, hotel);
        break;
      case 'add_vendor':
        _showAddVendorDialog(context, hotel);
        break;
      case 'delete':
        _showDeleteConfirmation(context, hotel);
        break;
    }
  }

  void _showAddHotelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddHotelDialog(),
    );
  }

  void _showEditHotelDialog(BuildContext context, Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => AddHotelDialog(hotel: hotel),
    );
  }

  void _showAddVendorDialog(BuildContext context, [Hotel? hotel]) {
    showDialog(
      context: context,
      builder: (context) => AddVendorDialog(hotel: hotel),
    );
  }

  void _showEditVendorDialog(BuildContext context, Vendor vendor) {
    showDialog(
      context: context,
      builder: (context) => AddVendorDialog(vendor: vendor),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotel'),
        content: Text('Are you sure you want to delete "${hotel.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HotelProvider>().deleteHotel(hotel.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}