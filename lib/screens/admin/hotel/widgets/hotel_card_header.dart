import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/models/hotel.dart';

class HotelCardHeader extends StatelessWidget {
  final Hotel hotel;
  final bool canEdit;
  final bool isCheckingPermission;
  final Animation<double> rotationAnimation;
  final Function(String) onMenuAction;

  const HotelCardHeader({
    super.key,
    required this.hotel,
    required this.canEdit,
    required this.isCheckingPermission,
    required this.rotationAnimation,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
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
                hotel.name,
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
                      hotel.address,
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
          animation: rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: rotationAnimation.value * 3.14159,
              child: Icon(
                Icons.expand_more,
                color: AppColors.primary,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Actions menu
        if (!isCheckingPermission && canEdit)
          PopupMenuButton<String>(
            onSelected: onMenuAction,
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
                value: 'manage_menu',
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, size: 18),
                    SizedBox(width: 8),
                    Text('Manage Menu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_menu_item',
                child: Row(
                  children: [
                    Icon(Icons.add_box, size: 18),
                    SizedBox(width: 8),
                    Text('Add Menu Item'),
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
}