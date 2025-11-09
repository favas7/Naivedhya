import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:naivedhya/services/manager_service.dart';
import 'package:naivedhya/services/location_service.dart';
import 'package:naivedhya/services/menu_service.dart';
import 'package:naivedhya/utils/color_theme.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final RestaurantService _restaurantService = RestaurantService();
  final ManagerService _managerService = ManagerService();
  final LocationService _locationService = LocationService();
  final MenuService _menuService = MenuService();

  // Data
  List<Manager> _managers = [];
  List<Location> _locations = [];
  List<MenuItem> _menuItems = [];
  Map<String, int> _stats = {};

  // Loading states
  bool _isLoadingManagers = true;
  bool _isLoadingLocations = true;
  bool _isLoadingMenuItems = true;
  bool _isLoadingStats = true;

  // Error states
  String? _managersError;
  String? _locationsError;
  String? _menuItemsError;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadManagers(),
      _loadLocations(),
      _loadMenuItems(),
      _loadStats(),
    ]);
  }

  Future<void> _loadManagers() async {
    if (widget.restaurant.id == null) return;
    
    setState(() {
      _isLoadingManagers = true;
      _managersError = null;
    });

    try {
      // Get manager for this restaurant
      final manager = await _managerService.getManagerByrestaurantId(widget.restaurant.id!);
      setState(() {
        _managers = manager != null ? [manager] : [];
        _isLoadingManagers = false;
      });
    } catch (e) {
      setState(() {
        _managersError = e.toString();
        _isLoadingManagers = false;
      });
    }
  }

// Updated _loadLocations to fetch list
Future<void> _loadLocations() async {
  if (widget.restaurant.id == null) {
    print('Restaurant ID is null');
    return;
  }
  
  setState(() {
    _isLoadingLocations = true;
    _locationsError = null;
  });

  try {
    print('Fetching locations for restaurant: ${widget.restaurant.id}');
    final locations = await _locationService.getLocationsByRestaurantId(widget.restaurant.id!);  // ✅ Now fetches List
    print('Locations fetched: ${locations.length}');
    setState(() {
      _locations = locations;  // ✅ Direct assignment (no [location] wrapper)
      _isLoadingLocations = false;
    });
  } catch (e) {
    print('Error loading locations: $e');
    setState(() {
      _locationsError = e.toString();
      _isLoadingLocations = false;
    });
  }
}

  Future<void> _loadMenuItems() async {
    if (widget.restaurant.id == null) return;
    
    setState(() {
      _isLoadingMenuItems = true;
      _menuItemsError = null;
    });

    try {
      final items = await _menuService.getMenuItems(widget.restaurant.id!);
      setState(() {
        _menuItems = items;
        _isLoadingMenuItems = false;
      });
    } catch (e) {
      setState(() {
        _menuItemsError = e.toString();
        _isLoadingMenuItems = false;
      });
    }
  }

  Future<void> _loadStats() async {
    if (widget.restaurant.id == null) return;
    
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final results = await Future.wait([
        _restaurantService.getRestaurantCounts(widget.restaurant.id!),
        _menuService.getMenuItemCount(widget.restaurant.id!),
        _menuService.getAvailableMenuItemCount(widget.restaurant.id!),
      ]);

      final restaurantCounts = results[0] as Map<String, int>;
      setState(() {
        _stats = {
          'managers': restaurantCounts['managers'] ?? 0,
          'locations': restaurantCounts['locations'] ?? 0,
          'totalMenuItems': results[1] as int,
          'availableMenuItems': results[2] as int,
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _statsError = e.toString();
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(colors),
          
          // Restaurant Header
          SliverToBoxAdapter(
            child: _buildRestaurantHeader(colors),
          ),

          // Statistics Cards
          SliverToBoxAdapter(
            child: _buildStatistics(colors),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: colors.primary,
                unselectedLabelColor: colors.textSecondary,
                indicatorColor: colors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Managers'),
                  Tab(text: 'Locations'),
                  Tab(text: 'Menu Items'),
                ],
              ),
              colors.surface,
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(colors),
                _buildManagersTab(colors),
                _buildLocationsTab(colors),
                _buildMenuItemsTab(colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppThemeColors colors) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Restaurant Details',
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: colors.textSecondary),
          onPressed: _loadAllData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: Icon(Icons.edit, color: colors.primary),
          onPressed: () {
            // TODO: Navigate to edit screen
          },
          tooltip: 'Edit Restaurant',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildRestaurantHeader(AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.1),
            colors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Restaurant Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.success.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Restaurant Details
          _buildInfoRow(Icons.location_on, 'Address', widget.restaurant.address, colors),
          const SizedBox(height: 12),
          if (widget.restaurant.adminEmail != null)
            _buildInfoRow(Icons.email, 'Admin Email', widget.restaurant.adminEmail!, colors),
          if (widget.restaurant.adminEmail != null)
            const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Created',
            _formatDateTime(widget.restaurant.createdAt),
            colors,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.fingerprint,
            'Restaurant ID',
            widget.restaurant.id?.substring(0, 16) ?? 'N/A',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, AppThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(AppThemeColors colors) {
    if (_isLoadingStats) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (_statsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Error loading statistics',
          style: TextStyle(color: colors.error),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Managers',
              _stats['managers']?.toString() ?? '0',
              Icons.people,
              colors.primary,
              colors,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Locations',
              _stats['locations']?.toString() ?? '0',
              Icons.location_on,
              colors.success,
              colors,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Menu Items',
              '${_stats['availableMenuItems'] ?? 0}/${_stats['totalMenuItems'] ?? 0}',
              Icons.restaurant_menu,
              colors.warning,
              colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// Updated _buildOverviewTab to handle multiple locations safely
Widget _buildOverviewTab(AppThemeColors colors) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Quick summary cards
        _buildSummaryCard(
          'Manager Summary',
          _managers.isEmpty 
            ? 'No manager assigned' 
            : '${_managers.first.name} - ${_managers.first.email}',
          Icons.person,
          colors,
        ),
        const SizedBox(height: 12),
        
        _buildSummaryCard(
          'Location Summary',
          _locations.isEmpty 
            ? 'No locations added' 
            : _locations.length > 1 
                ? '${_locations.length} locations (Primary: ${_locations.first.city}, ${_locations.first.state})'  // ✅ Handle multiple: show count + first
                : '${_locations.first.city}, ${_locations.first.state}',  // Single case
          Icons.location_on,
          colors,
        ),
        const SizedBox(height: 12),
        
        _buildSummaryCard(
          'Menu Summary',
          '${_stats['availableMenuItems'] ?? 0} available items out of ${_stats['totalMenuItems'] ?? 0} total items',
          Icons.restaurant_menu,
          colors,
        ),
      ],
    ),
  );
}

  Widget _buildSummaryCard(String title, String content, IconData icon, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagersTab(AppThemeColors colors) {
    if (_isLoadingManagers) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (_managersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading managers',
              style: TextStyle(color: colors.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadManagers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_managers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: colors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No managers assigned',
              style: TextStyle(
                fontSize: 18,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a manager to manage this restaurant',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add manager
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Manager'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _managers.length,
      itemBuilder: (context, index) {
        final manager = _managers[index];
        return _buildManagerCard(manager, colors);
      },
    );
  }

  Widget _buildManagerCard(Manager manager, AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Manager Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.primary.withOpacity(0.1),
            backgroundImage: manager.imageUrl != null && manager.imageUrl!.isNotEmpty
                ? NetworkImage(manager.imageUrl!)
                : null,
            child: manager.imageUrl == null || manager.imageUrl!.isEmpty
                ? Icon(Icons.person, size: 32, color: colors.primary)
                : null,
          ),
          const SizedBox(width: 16),
          
          // Manager Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        manager.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      manager.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: Icon(Icons.edit, color: colors.primary),
            onPressed: () {
              // TODO: Edit manager
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab(AppThemeColors colors) {
    if (_isLoadingLocations) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (_locationsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading locations',
              style: TextStyle(color: colors.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadLocations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: colors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No locations added',
              style: TextStyle(
                fontSize: 18,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a location for this restaurant',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add location
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        return _buildLocationCard(location, colors);
      },
    );
  }

  Widget _buildLocationCard(Location location, AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on, color: colors.success, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.city,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.state,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: colors.primary),
                onPressed: () {
                  // TODO: Edit location
                },
              ),
            ],
          ),
          // ignore: unnecessary_null_comparison
          if (location.city != null || location.state != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                ...[
                Icon(Icons.location_city, size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  location.city,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                ...[
                const SizedBox(width: 16),
                Text(
                  '•',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(width: 16),
              ],
              ],
                ...[
                Icon(Icons.map, size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  location.state,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItemsTab(AppThemeColors colors) {
    if (_isLoadingMenuItems) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (_menuItemsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading menu items',
              style: TextStyle(color: colors.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMenuItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_outlined, size: 64, color: colors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No menu items',
              style: TextStyle(
                fontSize: 18,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add menu items to this restaurant',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add menu item
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Menu Item'),
            ),
          ],
        ),
      );
    }

    // Group menu items by category
    final Map<String?, List<MenuItem>> categorizedItems = {};
    for (var item in _menuItems) {
      final category = item.category ?? 'Uncategorized';
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: categorizedItems.length,
      itemBuilder: (context, index) {
        final category = categorizedItems.keys.elementAt(index);
        final items = categorizedItems[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category ?? 'Uncategorized',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
            
            // Menu Items in this category
            ...items.map((item) => _buildMenuItemCard(item, colors)),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item, AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Item Icon/Image placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.isAvailable 
                  ? colors.primary.withOpacity(0.1)
                  : colors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: item.isAvailable ? colors.primary : colors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.isAvailable
                            ? colors.success.withOpacity(0.1)
                            : colors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item.isAvailable ? colors.success : colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ...[
                    Icon(Icons.inventory_2, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${item.stockQuantity}',
                      style: TextStyle(
                        fontSize: 13,
                        color: item.isLowStock ? colors.warning : colors.textSecondary,
                        fontWeight: item.isLowStock ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                  ],
                ),
              ],
            ),
          ),
          
          // Edit button
          IconButton(
            icon: Icon(Icons.edit, color: colors.primary, size: 20),
            onPressed: () {
              // TODO: Edit menu item
            },
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Custom delegate for sticky tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}