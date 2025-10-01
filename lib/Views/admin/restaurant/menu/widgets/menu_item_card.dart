import 'package:flutter/material.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import 'package:naivedhya/models/menu_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAvailability;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onEdit,
    this.onDelete,
    this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: menuItem.isAvailable 
              ? null 
              : Border.all(color: Colors.red.withAlpha(0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: menuItem.isAvailable 
                          ? AppColors.primary.withAlpha(0)
                          : Colors.grey.withAlpha(0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: menuItem.isAvailable 
                          ? AppColors.primary
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                menuItem.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: menuItem.isAvailable 
                                      ? Colors.black87
                                      : Colors.grey[600],
                                  decoration: menuItem.isAvailable 
                                      ? null 
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            Text(
                              '₹${menuItem.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: menuItem.isAvailable 
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        // Description
                        if (menuItem.description != null && menuItem.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            menuItem.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        // Category and Availability Row
                        Row(
                          children: [
                            // Category Chip
                            if (menuItem.category != null && menuItem.category!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  menuItem.category!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            
                            const Spacer(),
                            
                            // Availability Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: menuItem.isAvailable 
                                    ? Colors.green.withAlpha(0)
                                    : Colors.red.withAlpha(0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    menuItem.isAvailable 
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 14,
                                    color: menuItem.isAvailable 
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    menuItem.isAvailable ? 'Available' : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: menuItem.isAvailable 
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                      fontWeight: FontWeight.w500,
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
                  
                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle_availability',
                        child: Row(
                          children: [
                            Icon(
                              menuItem.isAvailable 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(menuItem.isAvailable 
                                ? 'Mark Unavailable' 
                                : 'Mark Available'),
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
              
              // Item ID and Timestamps (if needed for debugging)
              if (menuItem.createdAt != null) ...[
                const SizedBox(height: 8),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${_formatDateTime(menuItem.createdAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (menuItem.updatedAt != null && 
                        menuItem.updatedAt != menuItem.createdAt) ...[
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Text(
                        'Updated: ${_formatDateTime(menuItem.updatedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'toggle_availability':
        onToggleAvailability?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}