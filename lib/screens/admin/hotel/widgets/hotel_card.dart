import 'package:flutter/material.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/screens/admin/hotel/menu/menu_managment_screen.dart';
import 'package:naivedhya/screens/admin/hotel/menu/widgets/add_menu_item.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_location_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_manager_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/edithotel_basic_info.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card_basic_info.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card_expanded.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card_header.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card_meta_info.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card_status_row.dart';
import 'package:naivedhya/services/hotel_service.dart';
import 'package:naivedhya/services/menu_service.dart';


class ExpandableHotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onHotelUpdated;

  const ExpandableHotelCard({
    super.key,
    required this.hotel,
    this.onHotelUpdated,
  });

  @override
  State<ExpandableHotelCard> createState() => _ExpandableHotelCardState();
}

class _ExpandableHotelCardState extends State<ExpandableHotelCard>
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
    if (widget.hotel.id != null) {
      final canEdit = await _supabaseService.canEditHotel(widget.hotel.id!);
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
    if (widget.hotel.id != null) {
      try {
        final results = await Future.wait([
          _supabaseService.getHotelCounts(widget.hotel.id!),
          _menuService.getMenuItemCount(widget.hotel.id!),
          _menuService.getAvailableMenuItemCount(widget.hotel.id!),
        ]);
        
        if (mounted) {
          final hotelCounts = results[0] as Map<String, int>;
          setState(() {
            _managerCount = hotelCounts['managers'] ?? 0;
            _locationCount = hotelCounts['locations'] ?? 0;
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
    if (widget.hotel.id == null) return;
    
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final results = await Future.wait([
        _supabaseService.getManagers(widget.hotel.id!),
        _supabaseService.getLocations(widget.hotel.id!),
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
          hotel: widget.hotel,
          onMenuUpdated: _refreshData,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit_basic':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditHotelBasicInfoDialog(
            hotel: widget.hotel,
            onSuccess: () {
              widget.onHotelUpdated?.call();
            },
          ),
        );
        if (result == true) _refreshData();
        break;
        
      case 'manage_menu':
        _navigateToMenuManagement();
        break;
        
      case 'add_menu_item':
        if (widget.hotel.id != null) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AddEditMenuItemDialog(
              hotelId: widget.hotel.id!,
              onSuccess: _refreshData, categories: [],
            ),
          );
          if (result == true) _refreshData();
        }
        break;
        
      case 'add_manager':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AddManagerDialog(hotel: widget.hotel),
        );
        if (result == true) _refreshData();
        break;
        
      case 'add_location':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AddLocationDialog(hotel: widget.hotel),
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
        title: const Text('Delete Hotel'),
        content: Text('Are you sure you want to delete "${widget.hotel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHotel();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHotel() async {
    if (widget.hotel.id == null) return;

    try {
      final success = await _supabaseService.deleteHotel(widget.hotel.id!);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hotel deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onHotelUpdated?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete hotel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting hotel: $e'),
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
                  HotelCardHeader(
                    hotel: widget.hotel,
                    canEdit: _canEdit,
                    isCheckingPermission: _isCheckingPermission,
                    rotationAnimation: _rotationAnimation,
                    onMenuAction: _handleMenuAction,
                  ),
                  HotelCardBasicInfo(hotel: widget.hotel),
                  HotelCardStatusRow(
                    isLoadingCounts: _isLoadingCounts,
                    managerCount: _managerCount,
                    locationCount: _locationCount,
                    menuItemCount: _menuItemCount,
                    availableMenuItemCount: _availableMenuItemCount,
                    canEdit: _canEdit,
                    onNavigateToMenuManagement: _navigateToMenuManagement,
                  ),
                  HotelCardMetaInfo(hotel: widget.hotel),
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
            child: HotelCardExpandedContent(
              hotel: widget.hotel,
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
            ),
          ),
        ],
      ),
    );
  }
}