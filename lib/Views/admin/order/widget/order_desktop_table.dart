// widgets/order_desktop_table.dart (Updated)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/Views/admin/order/widget/delivery_assignment_dialogue.dart';
import 'package:naivedhya/Views/admin/order/widget/order_status.dart';

class OrderDesktopTable extends StatelessWidget {
  final List<Order> orders;
  final Function(Order) onViewDetails;
  final Function(Order) onEditOrder;
  final Function(String orderId, String deliveryPersonId)? onAssignDelivery;
  final Function(String orderId)? onUnassignDelivery;

  const OrderDesktopTable({
    super.key,
    required this.orders,
    required this.onViewDetails,
    required this.onEditOrder,
    this.onAssignDelivery,
    this.onUnassignDelivery,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'out for delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAssignDeliveryDialog(BuildContext context, Order order) {
    if (onAssignDelivery != null) {
      DeliveryAssignmentDialog.show(context, order, onAssignDelivery!);
    }
  }

  Future<void> _handleUnassignDelivery(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unassign Delivery Person'),
        content: Text(
          'Are you sure you want to unassign the delivery person from order ${order.orderNumber}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );

    if (confirmed == true && onUnassignDelivery != null) {
      try {
        await onUnassignDelivery!(order.orderId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery person unassigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unassign delivery person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
          columns: const [
            DataColumn(
              label: Text(
                'Order #',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Customer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Delivery Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Delivery Person',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.orderNumber,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(order.customerName ?? 'Unknown Customer'),
                ),
                DataCell(
                  Text(DateFormat('MMM dd, yyyy').format(order.createdAt)),
                ),
                DataCell(
                  OrderStatusChip(status: order.status),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeliveryStatusColor(order.deliveryStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.deliveryStatus ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  order.deliveryPersonId != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${order.deliveryPersonId!.substring(0, 8)}...',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Not Assigned',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                ),
                DataCell(
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () => onViewDetails(order),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => onEditOrder(order),
                        tooltip: 'Edit Order',
                      ),
                      if (order.deliveryPersonId == null)
                        IconButton(
                          icon: const Icon(
                            Icons.delivery_dining,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onPressed: onAssignDelivery != null
                              ? () => _showAssignDeliveryDialog(context, order)
                              : null,
                          tooltip: 'Assign Delivery',
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.person_remove,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: onUnassignDelivery != null
                              ? () => _handleUnassignDelivery(context, order)
                              : null,
                          tooltip: 'Unassign Delivery',
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getDeliveryStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'in_transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}