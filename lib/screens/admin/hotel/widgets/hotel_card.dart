import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_location_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_manager_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/edithotel_basic_info.dart';
import 'package:naivedhya/services/hotel_service.dart';

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
  
  bool _isExpanded = false;
  bool _canEdit = false;
  bool _isCheckingPermission = true;
  bool _isLoadingDetails = false;
  
  // Counts
  int _managerCount = 0;
  int _locationCount = 0;
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
      final counts = await _supabaseService.getHotelCounts(widget.hotel.id!);
      if (mounted) {
        setState(() {
          _managerCount = counts['managers'] ?? 0;
          _locationCount = counts['locations'] ?? 0;
          _isLoadingCounts = false;
        });
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
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildBasicInfo(),
                  const SizedBox(height: 12),
                  _buildStatusRow(),
                  const SizedBox(height: 8),
                  _buildMetaInfo(),
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
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hotel.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.hotel.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Expand/Collapse button
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Icon(
                Icons.expand_more,
                color: AppColors.primary,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Actions menu
        if (!_isCheckingPermission && _canEdit)
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_basic',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_manager',
                child: Row(
                  children: [
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 8),
                    Text('Add Manager'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_location',
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 18),
                    SizedBox(width: 8),
                    Text('Add Location'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    if (widget.hotel.adminEmail == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 14,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Admin: ${widget.hotel.adminEmail}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    if (_isLoadingCounts) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading status...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildStatusChip(
          icon: _managerCount > 0 ? Icons.person : Icons.person_outline,
          label: 'Managers: $_managerCount',
          isActive: _managerCount > 0,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          icon: _locationCount > 0 ? Icons.location_on : Icons.location_off,
          label: 'Locations: $_locationCount',
          isActive: _locationCount > 0,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (_managerCount > 0 && _locationCount > 0)
                ? Colors.green.withAlpha(30)
                : Colors.red.withAlpha(30),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            (_managerCount > 0 && _locationCount > 0)
                ? Icons.check_circle
                : Icons.warning,
            size: 16,
            color: (_managerCount > 0 && _locationCount > 0)
                ? Colors.green[700]
                : Colors.red[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.green.withAlpha(30) 
            : Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive 
                ? Colors.green[700] 
                : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive 
                  ? Colors.green[700] 
                  : Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    if (widget.hotel.createdAt == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          'Created: ${_formatDate(widget.hotel.createdAt!)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingDetails)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildDetailedInfo(),
              const SizedBox(height: 16),
              _buildManagersSection(),
              const SizedBox(height: 16),
              _buildLocationsSection(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hotel Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Hotel ID', widget.hotel.id ?? 'N/A'),
        _buildDetailRow('Enterprise ID', widget.hotel.enterpriseId ?? 'N/A'),
        if (widget.hotel.updatedAt != null)
          _buildDetailRow('Last Updated', _formatDateTime(widget.hotel.updatedAt!)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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

  Widget _buildManagersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Managers ($_managerCount)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_canEdit)
              TextButton.icon(
                onPressed: () => _handleMenuAction('add_manager'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_managers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No managers assigned',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ..._managers.map((manager) => _buildManagerCard(manager)),
      ],
    );
  }

  Widget _buildManagerCard(Manager manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  manager.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  manager.phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Locations ($_locationCount)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_canEdit)
              TextButton.icon(
                onPressed: () => _handleMenuAction('add_location'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_locations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No locations assigned',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ..._locations.map((location) => _buildLocationCard(location)),
      ],
    );
  }

  Widget _buildLocationCard(Location location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.fullAddress,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${location.id ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_canEdit) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionChip(
              icon: Icons.edit,
              label: 'Edit Info',
              onTap: () => _handleMenuAction('edit_basic'),
            ),
            _buildActionChip(
              icon: Icons.person_add,
              label: 'Add Manager',
              onTap: () => _handleMenuAction('add_manager'),
            ),
            _buildActionChip(
              icon: Icons.location_on,
              label: 'Add Location',
              onTap: () => _handleMenuAction('add_location'),
            ),
            _buildActionChip(
              icon: Icons.refresh,
              label: 'Refresh',
              onTap: _refreshData,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}