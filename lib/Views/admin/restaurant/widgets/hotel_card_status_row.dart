import 'package:flutter/material.dart';
import 'package:naivedhya/utils/constants/colors.dart';

class RestaurantCardStatusRow extends StatelessWidget {
  final bool isLoadingCounts;
  final int managerCount;
  final int locationCount;
  final int menuItemCount;
  final int availableMenuItemCount;
  final bool canEdit;
  final VoidCallback onNavigateToMenuManagement;

  const RestaurantCardStatusRow({
    super.key,
    required this.isLoadingCounts,
    required this.managerCount,
    required this.locationCount,
    required this.menuItemCount,
    required this.availableMenuItemCount,
    required this.canEdit,
    required this.onNavigateToMenuManagement,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingCounts) {
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

    return Column(
      children: [
        // First row - Managers and Locations
        Row(
          children: [
            _buildStatusChip(
              icon: managerCount > 0 ? Icons.person : Icons.person_outline,
              label: 'Managers: $managerCount',
              isActive: managerCount > 0,
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              icon: locationCount > 0 ? Icons.location_on : Icons.location_off,
              label: 'Locations: $locationCount',
              isActive: locationCount > 0,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (managerCount > 0 && locationCount > 0)
                    ? Colors.green.withAlpha(30)
                    : Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                (managerCount > 0 && locationCount > 0)
                    ? Icons.check_circle
                    : Icons.warning,
                size: 16,
                color: (managerCount > 0 && locationCount > 0)
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row - Menu Items
        Row(
          children: [
            _buildStatusChip(
              icon: menuItemCount > 0 ? Icons.restaurant_menu : Icons.menu_book_outlined,
              label: 'Menu Items: $menuItemCount',
              isActive: menuItemCount > 0,
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              icon: availableMenuItemCount > 0 ? Icons.check_circle : Icons.cancel,
              label: 'Available: $availableMenuItemCount',
              isActive: availableMenuItemCount > 0,
            ),
            const Spacer(),
            if (canEdit)
              InkWell(
                onTap: onNavigateToMenuManagement,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manage Menu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
}