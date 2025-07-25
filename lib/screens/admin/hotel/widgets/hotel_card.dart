import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_location_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_manager_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/edithotel_basic_info.dart';
import 'package:naivedhya/services/hotel_service.dart';
    
class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback? onHotelUpdated; // Callback for when hotel is updated

  const HotelCard({
    super.key,
    required this.hotel,
    this.onHotelUpdated,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _canEdit = false;
  bool _isCheckingPermission = true;
  int _managerCount = 0;
  int _locationCount = 0;
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _checkEditPermission();
    _loadCounts();
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

  // Refresh counts after adding manager/location
  Future<void> _refreshCounts() async {
    setState(() {
      _isLoadingCounts = true;
    });
    await _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                // Show edit/actions menu only if user can edit
                if (!_isCheckingPermission && _canEdit)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditDialog();
                          break;
                        case 'edit_basic':
                          _showEditBasicInfoDialog();
                          break;
                        case 'delete':
                          _showDeleteConfirmation();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 18),
                            SizedBox(width: 8),
                            Text('Manage'),
                          ],
                        ),
                      ),
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
            ),
            const SizedBox(height: 12),
            
            // Show admin email if it exists
            if (widget.hotel.adminEmail != null)
              Container(
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
              ),

            const SizedBox(height: 12),

            // Manager and Location Status
            if (!_isLoadingCounts) ...[
              Row(
                children: [
                  // Manager Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _managerCount > 0 
                          ? Colors.green.withAlpha(30) 
                          : Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _managerCount > 0 ? Icons.person : Icons.person_outline,
                          size: 14,
                          color: _managerCount > 0 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Managers: $_managerCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: _managerCount > 0 
                                ? Colors.green[700] 
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Location Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _locationCount > 0 
                          ? Colors.green.withAlpha(30) 
                          : Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _locationCount > 0 ? Icons.location_on : Icons.location_off,
                          size: 14,
                          color: _locationCount > 0 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Locations: $_locationCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: _locationCount > 0 
                                ? Colors.green[700] 
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Overall Status Indicator
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
              ),
            ] else ...[
              Row(
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
              ),
            ],

            const SizedBox(height: 8),
            
            // Additional hotel info
            Row(
              children: [
                if (widget.hotel.createdAt != null) ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditBasicInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => EditHotelBasicInfoDialog(
        hotel: widget.hotel,
        onSuccess: () {
          widget.onHotelUpdated?.call();
        },
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant, color: AppColors.primary), 
                      const SizedBox(width: 8),
                      const Text(
                        'Manage Hotel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Hotel Info Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hotel: ${widget.hotel.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.hotel.id}', 
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Row
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: _managerCount > 0 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Managers: $_managerCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: _managerCount > 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: _locationCount > 0 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Locations: $_locationCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: _locationCount > 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Column(
                children: [
                  // Add Manager Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close current dialog
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AddManagerDialog(hotel: widget.hotel),
                        );
                        if (result == true) {
                          _refreshCounts();
                        }
                      },
                      icon: const Icon(Icons.person_add),
                      label: Text(_managerCount > 0 ? 'Add Another Manager' : 'Add Manager'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Add Location Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close current dialog
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AddLocationDialog(hotel: widget.hotel),
                        );
                        if (result == true) {
                          _refreshCounts();
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      label: Text(_locationCount > 0 ? 'Add Another Location' : 'Add Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
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
}