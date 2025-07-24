// widgets/order_desktop_table.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/screens/admin/order/widget/order_status.dart';


class OrderDesktopTable extends StatelessWidget {
  final List<Order> orders;
  final Function(Order) onViewDetails;
  final Function(Order) onEditOrder;

  const OrderDesktopTable({
    super.key,
    required this.orders,
    required this.onViewDetails,
    required this.onEditOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(
            label: Text(
              'Order ID',
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
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(order.customerName ?? 'Unknown'),
              ),
              DataCell(
                Text(DateFormat('MMM dd, yyyy').format(order.createdAt)),
              ),
              DataCell(
                OrderStatusChip(status: order.status),
              ),
              DataCell(
                Text(order.deliveryStatus ?? 'N/A'),
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
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}