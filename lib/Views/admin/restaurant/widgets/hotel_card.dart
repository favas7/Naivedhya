import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/restaurant/location/add_location_dialogue.dart';
import 'package:naivedhya/Views/admin/restaurant/manager/add_manager_dialogue.dart';
import 'package:naivedhya/Views/admin/restaurant/manager/edit_manager.dart';
import 'package:naivedhya/Views/admin/restaurant/menu/menu_managment_screen.dart';
import 'package:naivedhya/Views/admin/restaurant/menu/widgets/add_menu_item.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/edithotel_basic_info.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card_basic_info.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card_expanded.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card_header.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card_meta_info.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card_status_row.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/services/hotel_service.dart';
import 'package:naivedhya/services/menu_service.dart';

class ExpandableRestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback? onRestaurantUpdated;

  const ExpandableRestaurantCard({
    super.key,
    required this.restaurant,
    this.onRestaurantUpdated,
  });

  @override
  State<ExpandableRestaurantCard> createState() => _ExpandableRestaurantCardState();
}

class _ExpandableRestaurantCardState extends State<ExpandableRestaurantCard>
    with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final MenuService _menuService = MenuService();
  
  bool _isExpanded = false;
  bool _canEdit = false;
  bool _isCheckingPermission = true;
  bool _isLoadingDetails = false;
  
  // Counts
  int _managerCount = 0;
  int _locationCount = 0;
  int _menuItemCount = 0;
  int _availableMenuItemCount = 0;
  bool _isLoadingCounts = true;
  
  // Detailed data
  List<Manager> _managers = [];
  List<Location> _locations = [];
  
  // Animation controllers
  late AnimationController _expandController;
  late AnimationController _rotationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkEditPermission();
    _loadCounts();
  }

  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _checkEditPermission() async {
    if (widget.restaurant.id != null) {
      final canEdit = await _supabaseService.canEditRestaurant(widget.restaurant.id!);
      if (mounted) {
        setState(() {
          _canEdit = canEdit;
          _isCheckingPermission = false;
        });
      }
    } else {
      setState(() {
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _loadCounts() async {
    if (widget.restaurant.id != null) {
      try {
        final results = await Future.wait([
          _supabaseService.getRestaurantCounts(widget.restaurant.id!),
          _menuService.getMenuItemCount(widget.restaurant.id!),
          _menuService.getAvailableMenuItemCount(widget.restaurant.id!),
        ]);
        
        if (mounted) {
          final restaurantCounts = results[0] as Map<String, int>;
          setState(() {
            _managerCount = restaurantCounts['managers'] ?? 0;
            _locationCount = restaurantCounts['locations'] ?? 0;
            _menuItemCount = results[1] as int;
            _availableMenuItemCount = results[2] as int;
            _isLoadingCounts = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingCounts = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingCounts = false;
      });
    }
  }

  Future<void> _loadDetailedData() async {
    if (widget.restaurant.id == null) return;
    
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final results = await Future.wait([
        _supabaseService.getManagers(widget.restaurant.id!),
        _supabaseService.getLocations(widget.restaurant.id!),
      ]);

      if (mounted) {
        setState(() {
          _managers = results[0] as List<Manager>;
          _locations = results[1] as List<Location>;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadCounts(),
      if (_isExpanded) _loadDetailedData(),
    ]);
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
      _rotationController.forward();
      _loadDetailedData();
    } else {
      _expandController.reverse();
      _rotationController.reverse();
    }
  }

  void _navigateToMenuManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuManagementScreen(
          restaurant: widget.restaurant,
          onMenuUpdated: _refreshData,
        ),
      ),
    );
  }

  // NEW: Method to handle manager editing
  Future<void> _editManager(Manager manager) async {
    final updatedManager = await showDialog<Manager>(
      context: context,
      builder: (context) => EditManagerDialog(
        manager: manager,
        restaurant: widget.restaurant,
      ),
    );

    if (updatedManager != null) {
      // Update the local manager list
      setState(() {
        final index = _managers.indexWhere((m) => m.id == updatedManager.id);
        if (index != -1) {
          _managers[index] = updatedManager;
        }
      });
      
      // Optionally refresh counts to ensure consistency
      await _loadCounts();
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit_basic':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditRestaurantBasicInfoDialog(
            restaurant: widget.restaurant,
            onSuccess: () {
              widget.onRestaurantUpdated?.call();
            },
          ),
        );
        if (result == true) _refreshData();
        break;
        
      case 'manage_menu':
        _navigateToMenuManagement();
        break;
        
      case 'add_menu_item':
        if (widget.restaurant.id != null) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AddEditMenuItemDialog(
              RestaurantId: widget.restaurant.id!,
              onSuccess: _refreshData, 
              categories: [],
            ),
          );
          if (result == true) _refreshData();
        }
        break;
        
      case 'add_manager':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AddManagerDialog(restaurant: widget.restaurant),
        );
        if (result == true) _refreshData();
        break;
        
      case 'add_location':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AddLocationDialog(restaurant: widget.restaurant),
        );
        if (result == true) _refreshData();
        break;
        
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Are you sure you want to delete "${widget.restaurant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRestaurant();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRestaurant() async {
    if (widget.restaurant.id == null) return;

    try {
      final success = await _supabaseService.deleteRestaurant(widget.restaurant.id!);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRestaurantUpdated?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete Restaurant'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting Restaurant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Main card content
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestaurantCardHeader(
                    restaurant: widget.restaurant,
                    canEdit: _canEdit,
                    isCheckingPermission: _isCheckingPermission,
                    rotationAnimation: _rotationAnimation,
                    onMenuAction: _handleMenuAction,
                  ),
                  RestaurantCardBasicInfo(restaurant: widget.restaurant),
                  RestaurantCardStatusRow(
                    isLoadingCounts: _isLoadingCounts,
                    managerCount: _managerCount,
                    locationCount: _locationCount,
                    menuItemCount: _menuItemCount,
                    availableMenuItemCount: _availableMenuItemCount,
                    canEdit: _canEdit,
                    onNavigateToMenuManagement: _navigateToMenuManagement,
                  ),
                  RestaurantCardMetaInfo(restaurant: widget.restaurant),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: RestaurantCardExpandedContent(
              restaurant: widget.restaurant,
              isLoadingDetails: _isLoadingDetails,
              managers: _managers,
              locations: _locations,
              managerCount: _managerCount,
              locationCount: _locationCount,
              menuItemCount: _menuItemCount,
              availableMenuItemCount: _availableMenuItemCount,
              canEdit: _canEdit,
              onMenuAction: _handleMenuAction,
              onNavigateToMenuManagement: _navigateToMenuManagement,
              onRefreshData: _refreshData,
              onEditManager: _editManager, // Pass the edit manager callback
            ),
          ),
        ],
      ),
    );
  }
}