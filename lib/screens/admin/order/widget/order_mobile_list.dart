// widgets/order_mobile_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/screens/admin/order/widget/order_status.dart';

class OrderMobileList extends StatelessWidget {
  final List<Order> orders;
  final Function(Order) onViewDetails;
  final Function(Order) onEditOrder;

  const OrderMobileList({
    super.key,
    required this.orders,
    required this.onViewDetails,
    required this.onEditOrder,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: orders.map((order) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status).withAlpha(1),
              child: Text(
                order.orderNumber.length >= 2
                    ? order.orderNumber.substring(order.orderNumber.length - 2)
                    : order.orderNumber,
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              order.customerName ?? 'Unknown Customer',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order: ${order.orderNumber}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OrderStatusChip(status: order.status),
                      const Spacer(),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Order'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  onViewDetails(order);
                } else if (value == 'edit') {
                  onEditOrder(order);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}