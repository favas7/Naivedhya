import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/add_hotel_dialogue.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/restaurant_card.dart';
import 'package:naivedhya/providers/restaurant_provider.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:naivedhya/services/menu_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class RestaurantScreenEnhanced extends StatelessWidget {
  const RestaurantScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => RestaurantProvider(),
      child: const RestaurantScreenContent(),
    );
  }
}

class RestaurantScreenContent extends StatefulWidget {
  const RestaurantScreenContent({super.key});

  @override
  State<RestaurantScreenContent> createState() => _RestaurantScreenContentState();
}

class _RestaurantScreenContentState extends State<RestaurantScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date, managers, locations
  
  // Store restaurant stats
  final Map<String, Map<String, dynamic>> _restaurantStats = {};
  final RestaurantService _supabaseService = RestaurantService();
  final MenuService _menuService = MenuService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurants();
    });
  }
 
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.loadRestaurants();
    
    // Load stats for all restaurants
    for (var restaurant in provider.restaurants) {
      if (restaurant.id != null) {
        _loadRestaurantStats(restaurant.id!);
      }
    }
  }

  Future<void> _loadRestaurantStats(String restaurantId) async {
    try {
      final results = await Future.wait([
        _supabaseService.getRestaurantCounts(restaurantId),
        _menuService.getMenuItemCount(restaurantId),
        _menuService.getAvailableMenuItemCount(restaurantId), 
        _supabaseService.canEditRestaurant(restaurantId),
      ]);

      if (mounted) {
        setState(() {
          final restaurantCounts = results[0] as Map<String, int>;
          _restaurantStats[restaurantId] = {
            'managerCount': restaurantCounts['managers'] ?? 0,
            'locationCount': restaurantCounts['locations'] ?? 0,
            'menuItemCount': results[1] as int,
            'availableMenuItemCount': results[2] as int,
            'canEdit': results[3] as bool,
          };
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showAddRestaurantDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddRestaurantDialog(),
    );

    if (result == true && mounted) {
      _loadRestaurants();
    }
  }

  void _refreshRestaurants() {
    _loadRestaurants();
  }

  List<dynamic> _getFilteredAndSortedRestaurants(List restaurants) {
    var filtered = restaurants.where((restaurant) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.address.toLowerCase().contains(query);
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case 'managers':
        filtered.sort((a, b) {
          final aStats = _restaurantStats[a.id];
          final bStats = _restaurantStats[b.id];
          final aCount = aStats?['managerCount'] ?? 0;
          final bCount = bStats?['managerCount'] ?? 0;
          return bCount.compareTo(aCount);
        });
        break;
      case 'locations':
        filtered.sort((a, b) {
          final aStats = _restaurantStats[a.id];
          final bStats = _restaurantStats[b.id];
          final aCount = aStats?['locationCount'] ?? 0;
          final bCount = bStats?['locationCount'] ?? 0;
          return bCount.compareTo(aCount);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Restaurants...',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null && provider.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshRestaurants,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredRestaurants = _getFilteredAndSortedRestaurants(provider.restaurants);

          if (provider.restaurants.isEmpty) {
            return _buildEmptyState(colors);
          }

          return Column(
            children: [
              // Header with Search and Filters
              _buildHeader(colors, provider.restaurants.length),
              
              // Restaurant Grid
              Expanded(
                child: filteredRestaurants.isEmpty
                    ? _buildNoResultsState(colors)
                    : RefreshIndicator(
                        onRefresh: () async => _loadRestaurants(),
                        color: colors.primary,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 500,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 340,
                          ),
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = filteredRestaurants[index];
                            final stats = _restaurantStats[restaurant.id] ?? {
                              'managerCount': 0,
                              'locationCount': 0,
                              'menuItemCount': 0,
                              'availableMenuItemCount': 0,
                              'canEdit': false,
                            };

                            return EnhancedRestaurantCard(
                              restaurant: restaurant,
                              onRestaurantUpdated: _refreshRestaurants,
                              managerCount: stats['managerCount'] as int,
                              locationCount: stats['locationCount'] as int,
                              menuItemCount: stats['menuItemCount'] as int,
                              availableMenuItemCount: stats['availableMenuItemCount'] as int,
                              canEdit: stats['canEdit'] as bool,
                              onMenuAction: (action) => _handleMenuAction(action, restaurant),
                              onNavigateToMenuManagement: () {
                                // Navigate to menu management
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRestaurantDialog,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Restaurant',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCount ${totalCount == 1 ? 'Restaurant' : 'Restaurants'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refreshRestaurants,
                icon: Icon(Icons.refresh, color: colors.textSecondary),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Search Bar
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search restaurants by name or address...',
                    prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Sort Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                    DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
                    DropdownMenuItem(value: 'managers', child: Text('Sort by Managers')),
                    DropdownMenuItem(value: 'locations', child: Text('Sort by Locations')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: 60,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Restaurants Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first restaurant',
            style: TextStyle(
              fontSize: 16,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddRestaurantDialog,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Restaurant',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No restaurants found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, dynamic restaurant) {
    // Handle different menu actions
    switch (action) {
      case 'edit_basic':
        // Show edit dialog
        break;
      case 'add_manager':
        // Show add manager dialog
        break;
      case 'add_location':
        // Show add location dialog
        break;
      case 'delete':
        // Show delete confirmation
        break;
    }
  }
}