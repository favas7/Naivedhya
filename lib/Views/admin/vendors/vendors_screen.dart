// import 'package:flutter/material.dart';
// import 'package:naivedhya/Views/admin/vendors/vendor_details_screen/vendor_details_screen.dart';
// import 'package:naivedhya/Views/admin/vendors/widgets/add_ventor_dialogue.dart';
// import 'package:naivedhya/Views/admin/vendors/widgets/ventor_card.dart';
// import 'package:naivedhya/models/ventor_model.dart';
// import 'package:naivedhya/models/restaurant_model.dart';
// import 'package:naivedhya/services/ventor_Service.dart';
// import 'package:naivedhya/services/restaurant_service.dart';
// import 'package:naivedhya/utils/color_theme.dart';

// class VendorScreen extends StatefulWidget {
//   const VendorScreen({super.key});

//   @override
//   State<VendorScreen> createState() => _VendorScreenState();
// }

// class _VendorScreenState extends State<VendorScreen> {
//   final VendorService _vendorService = VendorService();
//   final RestaurantService _restaurantService = RestaurantService();

//   List<Vendor> _vendors = [];
//   List<Vendor> _filteredVendors = [];
//   final Map<String, String> _restaurantNames = {}; // vendorId -> restaurantName
//   List<String> _serviceTypes = [];
//   List<Restaurant> _restaurants = [];

//   bool _isLoading = true;
//   bool _isGridView = true; // Toggle between grid and list
//   String _searchQuery = '';
//   String _selectedServiceType = 'All';
//   String? _selectedRestaurantId;

//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     try {
//       // Load restaurants first
//       _restaurants = await _restaurantService.getRestaurants();

//       // Load all vendors
//       final vendorMaps = await _vendorService.fetchAllActiveVendors();
//       _vendors = vendorMaps.map((map) {
//         return Vendor(
//           id: map['vendor_id'],
//           name: map['name'] ?? 'Unknown',
//           email: map['email'] ?? '',
//           phone: map['phone'] ?? '',
//           serviceType: map['service_type'] ?? 'General',
//           restaurantId: map['hotel_id'],
//           isActive: true,
//         );
//       }).toList();

//       // Build restaurant names map
//       for (var vendor in _vendors) {
//         if (vendor.restaurantId != null) {
//           final restaurant = _restaurants.firstWhere(
//             (r) => r.id == vendor.restaurantId,
//             orElse: () => Restaurant(name: 'Unknown', address: ''),
//           );
//           _restaurantNames[vendor.id!] = restaurant.name;
//         }
//       }

//       // Extract unique service types
//       _serviceTypes = ['All', ..._vendors.map((v) => v.serviceType).toSet().toList()];

//       _filteredVendors = _vendors;
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading vendors: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _filterVendors() {
//     List<Vendor> filtered = _vendors;

//     // Filter by service type
//     if (_selectedServiceType != 'All') {
//       filtered = filtered.where((v) => v.serviceType == _selectedServiceType).toList();
//     }

//     // Filter by restaurant
//     if (_selectedRestaurantId != null) {
//       filtered = filtered.where((v) => v.restaurantId == _selectedRestaurantId).toList();
//     }

//     // Filter by search query
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((v) {
//         return v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             v.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             v.serviceType.toLowerCase().contains(_searchQuery.toLowerCase());
//       }).toList();
//     }

//     setState(() => _filteredVendors = filtered);
//   }

//   void _onSearchChanged(String query) {
//     setState(() => _searchQuery = query);
//     _filterVendors();
//   }

//   void _onServiceTypeChanged(String? type) {
//     setState(() => _selectedServiceType = type ?? 'All');
//     _filterVendors();
//   }

//   void _onRestaurantChanged(String? restaurantId) {
//     setState(() => _selectedRestaurantId = restaurantId);
//     _filterVendors();
//   }

//   // ✅ UPDATED: Pass restaurants to the dialog
//   Future<void> _showAddVendorDialog({Restaurant? restaurant}) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AddVendorDialog(
//         restaurant: restaurant,
//         availableRestaurants: _restaurants, // ✅ Pass the restaurants list
//       ),
//     );

//     if (result == true) {
//       _loadData();
//     }
//   }

//   Future<void> _showEditVendorDialog(Vendor vendor) async {
//   // Find the restaurant for this vendor
//   Restaurant? vendorRestaurant;
//   if (vendor.restaurantId != null) {
//     try {
//       vendorRestaurant = _restaurants.firstWhere(
//         (r) => r.id == vendor.restaurantId,
//       );
//     } catch (e) {
//       // Restaurant not found
//       vendorRestaurant = null;
//     }
//   }

//   final result = await showDialog<bool>(
//     context: context,
//     builder: (context) => AddVendorDialog(
//       vendor: vendor,
//       restaurant: vendorRestaurant,
//       availableRestaurants: _restaurants,
//     ),
//   );

//   if (result == true) {
//     _loadData();
//   }
// }

//   Future<void> _deleteVendor(Vendor vendor) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Vendor'),
//         content: Text('Are you sure you want to delete "${vendor.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && vendor.id != null) {
//       try {
//         await _vendorService.deleteVendor(vendor.id!);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Vendor deleted successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           _loadData();
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

// void _showVendorDetails(Vendor vendor) {
//   if (vendor.id != null) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VendorDetailsScreen(vendorId: vendor.id!),
//       ),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Vendor ID not found')),
//     );
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     final colors = AppTheme.of(context);

//     return Scaffold(
//       backgroundColor: colors.background,
//       body: Column(
//         children: [
//           _buildHeader(colors),
//           Expanded(
//             child: _isLoading ? _buildLoading(colors) : _buildContent(colors),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddVendorDialog(),
//         backgroundColor: colors.primary,
//         foregroundColor: Colors.white,
//         icon: const Icon(Icons.add),
//         label: const Text('Add Vendor'),
//       ),
//     );
//   }

//   Widget _buildHeader(AppThemeColors colors) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title Row
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Vendor Management',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Manage your restaurant vendors and suppliers',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: colors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // View Toggle
//               Container(
//                 decoration: BoxDecoration(
//                   color: colors.background,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.grid_view,
//                         color: _isGridView ? colors.primary : colors.textSecondary,
//                       ),
//                       onPressed: () => setState(() => _isGridView = true),
//                       tooltip: 'Grid View',
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.view_list,
//                         color: !_isGridView ? colors.primary : colors.textSecondary,
//                       ),
//                       onPressed: () => setState(() => _isGridView = false),
//                       tooltip: 'List View',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Search and Filters
//           Row(
//             children: [
//               // Search Bar
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: _onSearchChanged,
//                   decoration: InputDecoration(
//                     hintText: 'Search vendors...',
//                     prefixIcon: Icon(Icons.search, color: colors.textSecondary),
//                     filled: true,
//                     fillColor: colors.background,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Service Type Filter
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: colors.background,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: DropdownButton<String>(
//                   value: _selectedServiceType,
//                   underline: const SizedBox(),
//                   icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
//                   items: _serviceTypes.map((type) {
//                     return DropdownMenuItem(value: type, child: Text(type));
//                   }).toList(),
//                   onChanged: _onServiceTypeChanged,
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Restaurant Filter
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: colors.background,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: DropdownButton<String?>(
//                   value: _selectedRestaurantId,
//                   hint: const Text('All Restaurants'),
//                   underline: const SizedBox(),
//                   icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
//                   items: [
//                     const DropdownMenuItem<String?>(
//                       value: null,
//                       child: Text('All Restaurants'),
//                     ),
//                     ..._restaurants.map((restaurant) {
//                       return DropdownMenuItem<String?>(
//                         value: restaurant.id,
//                         child: Text(restaurant.name),
//                       );
//                     }).toList(),
//                   ],
//                   onChanged: _onRestaurantChanged,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoading(AppThemeColors colors) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: colors.primary),
//           const SizedBox(height: 16),
//           Text(
//             'Loading Vendors...',
//             style: TextStyle(fontSize: 16, color: colors.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(AppThemeColors colors) {
//     if (_filteredVendors.isEmpty) {
//       return _buildEmptyState(colors);
//     }

//     return RefreshIndicator(
//       onRefresh: _loadData,
//       color: colors.primary,
//       child: Column(
//         children: [
//           // Stats Bar
//           _buildStatsBar(colors),

//           // Vendors Grid/List
//           Expanded(
//             child: _isGridView ? _buildGridView() : _buildListView(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsBar(AppThemeColors colors) {
//     final activeCount = _vendors.where((v) => v.isActive).length;
//     final serviceTypeCount = _serviceTypes.length - 1; // Exclude 'All'

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         border: Border(
//           bottom: BorderSide(
//             color: colors.textSecondary.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem(colors, 'Total', _vendors.length.toString(), Icons.people),
//           _buildStatItem(colors, 'Active', activeCount.toString(), Icons.check_circle),
//           _buildStatItem(colors, 'Services', serviceTypeCount.toString(), Icons.business_center),
//           _buildStatItem(colors, 'Showing', _filteredVendors.length.toString(), Icons.visibility),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(AppThemeColors colors, String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: colors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 20, color: colors.primary),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: colors.textPrimary,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 11, color: colors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildGridView() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(24),
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 400,
//         childAspectRatio: 1.0,
//         crossAxisSpacing: 24,
//         mainAxisSpacing: 24,
//         mainAxisExtent: 280,
//       ),
//       itemCount: _filteredVendors.length,
//       itemBuilder: (context, index) {
//         final vendor = _filteredVendors[index];
//         return VendorCard(
//           vendor: vendor,
//           restaurantName: _restaurantNames[vendor.id],
//           onEdit: () => _showEditVendorDialog(vendor),
//           onDelete: () => _deleteVendor(vendor),
//           onViewDetails: () => _showVendorDetails(vendor),
//         );
//       },
//     );
//   }

//   Widget _buildListView() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(24),
//       itemCount: _filteredVendors.length,
//       itemBuilder: (context, index) {
//         final vendor = _filteredVendors[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: VendorCard(
//             vendor: vendor,
//             restaurantName: _restaurantNames[vendor.id],
//             onEdit: () => _showEditVendorDialog(vendor),
//             onDelete: () => _deleteVendor(vendor),
//             onViewDetails: () => _showVendorDetails(vendor),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(AppThemeColors colors) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: colors.primary.withAlpha(10),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               _vendors.isEmpty ? Icons.business_center : Icons.search_off,
//               size: 60,
//               color: colors.primary,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             _vendors.isEmpty ? 'No Vendors Yet' : 'No vendors found',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: colors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _vendors.isEmpty
//                 ? 'Start by adding your first vendor'
//                 : 'Try adjusting your search or filters',
//             style: TextStyle(fontSize: 16, color: colors.textSecondary),
//           ),
//           if (_vendors.isEmpty) ...[
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: () => _showAddVendorDialog(),
//               icon: const Icon(Icons.add),
//               label: const Text('Add Vendor'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colors.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }