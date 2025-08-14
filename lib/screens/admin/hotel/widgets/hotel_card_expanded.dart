import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/screens/admin/hotel/location/location_detail.dart';
import 'package:naivedhya/screens/admin/hotel/manager/manager_detail.dart';


class HotelCardExpandedContent extends StatelessWidget {
  final Hotel hotel;
  final bool isLoadingDetails;
  final List<Manager> managers;
  final List<Location> locations;
  final int managerCount;
  final int locationCount;
  final int menuItemCount;
  final int availableMenuItemCount;
  final bool canEdit;
  final Function(String) onMenuAction;
  final VoidCallback onNavigateToMenuManagement;
  final VoidCallback onRefreshData;

  const HotelCardExpandedContent({
    super.key,
    required this.hotel,
    required this.isLoadingDetails,
    required this.managers,
    required this.locations,
    required this.managerCount,
    required this.locationCount,
    required this.menuItemCount,
    required this.availableMenuItemCount,
    required this.canEdit,
    required this.onMenuAction,
    required this.onNavigateToMenuManagement,
    required this.onRefreshData, required Future<void> Function(Manager manager) onEditManager,
  });

  void _navigateToManagerDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerDetailScreen(
          hotel: hotel,
          onManagersUpdated: onRefreshData,
        ),
      ),
    );
  }

  void _navigateToLocationDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(
          hotel: hotel,
          onLocationsUpdated: onRefreshData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            if (isLoadingDetails)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildDetailedInfo(),
              const SizedBox(height: 16),
              _buildMenuSection(context),
              const SizedBox(height: 16),
              _buildManagersSection(context),
              const SizedBox(height: 16),
              _buildLocationsSection(context),
              const SizedBox(height: 16),
              _buildActionButtons(context),
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
        _buildDetailRow('Hotel ID', hotel.id ?? 'N/A'),
        _buildDetailRow('Enterprise ID', hotel.enterpriseId ?? 'N/A'),
        if (hotel.updatedAt != null)
          _buildDetailRow('Last Updated', _formatDateTime(hotel.updatedAt!)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu ($menuItemCount items)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (canEdit)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onMenuAction('add_menu_item'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onNavigateToMenuManagement,
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Manage'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (menuItemCount == 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No menu items added yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$menuItemCount menu items configured',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$availableMenuItemCount currently available for ordering',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  IconButton(
                    onPressed: onNavigateToMenuManagement,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Manage Menu',
                  ),
              ],
            ),
          ),
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

  Widget _buildManagersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Managers ($managerCount)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (canEdit)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onMenuAction('add_manager'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _navigateToManagerDetail(context),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (managers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'No managers assigned',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (canEdit)
                    ElevatedButton.icon(
                      onPressed: () => _navigateToManagerDetail(context),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Manage Managers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                ],
              ),
            ),
          )
        else ...[
          ...managers.take(2).map((manager) => _buildManagerCard(manager)),
          if (managers.length > 2)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () => _navigateToManagerDetail(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withAlpha(100)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary.withAlpha(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View ${managers.length - 2} more managers',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildLocationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Locations ($locationCount)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (canEdit)
              Row(
                children: [
                  // TextButton.icon(
                  //   onPressed: () => onMenuAction('add_location'),
                  //   icon: const Icon(Icons.add, size: 16),
                  //   label: const Text('Add'),
                  //   style: TextButton.styleFrom(
                  //     foregroundColor: AppColors.primary,
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _navigateToLocationDetail(context),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (locations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'No locations assigned',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (canEdit)
                    ElevatedButton.icon(
                      onPressed: () => _navigateToLocationDetail(context),
                      icon: const Icon(Icons.location_on, size: 16),
                      label: const Text('Manage Locations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                ],
              ),
            ),
          )
        else ...[
          ...locations.take(2).map((location) => _buildLocationCard(location)),
          if (locations.length > 2)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () => _navigateToLocationDetail(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withAlpha(100)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary.withAlpha(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View ${locations.length - 2} more locations',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildActionButtons(BuildContext context) {
    if (!canEdit) return const SizedBox.shrink();

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
              onTap: () => onMenuAction('edit_basic'),
            ),
            _buildActionChip(
              icon: Icons.restaurant_menu,
              label: 'Manage Menu',
              onTap: onNavigateToMenuManagement,
            ),
            _buildActionChip(
              icon: Icons.add_box,
              label: 'Add Menu Item',
              onTap: () => onMenuAction('add_menu_item'),
            ),
            _buildActionChip(
              icon: Icons.people,
              label: 'Manage Managers',
              onTap: () => _navigateToManagerDetail(context),
            ),
            _buildActionChip(
              icon: Icons.location_city,
              label: 'Manage Locations',
              onTap: () => _navigateToLocationDetail(context),
            ),
            _buildActionChip(
              icon: Icons.refresh,
              label: 'Refresh',
              onTap: onRefreshData,
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}