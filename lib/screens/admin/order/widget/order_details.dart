// widgets/order_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/screens/admin/order/widget/order_status.dart';


class OrderDetailsDialog extends StatelessWidget {
  final Order order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  static void show(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderDetailsDialog(order: order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Order Details - ${order.orderNumber}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailCard([
                _buildDetailRow('Order ID:', order.orderNumber),
                _buildDetailRow('Customer:', order.customerName ?? 'Unknown'),
                _buildDetailRow('Customer ID:', order.customerId),
                _buildDetailRow('Vendor ID:', order.vendorId),
                _buildDetailRow('Hotel ID:', order.hotelId),
              ]),
              const SizedBox(height: 16),
              _buildDetailCard([
                _buildDetailRowWithWidget('Status:', OrderStatusChip(status: order.status)),
                _buildDetailRow('Delivery Status:', order.deliveryStatus ?? 'N/A'),
                if (order.deliveryPersonId != null)
                  _buildDetailRow('Delivery Person ID:', order.deliveryPersonId!),
              ]),
              const SizedBox(height: 16),
              _buildDetailCard([
                _buildDetailRow('Total Amount:', '\$${order.totalAmount.toStringAsFixed(2)}'),
                _buildDetailRow('Order Date:', DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)),
                _buildDetailRow('Last Updated:', DateFormat('MMM dd, yyyy HH:mm').format(order.updatedAt)),
              ]),
              if (order.proposedDeliveryTime != null || 
                  order.pickupTime != null || 
                  order.deliveryTime != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard([
                  if (order.proposedDeliveryTime != null)
                    _buildDetailRow('Proposed Delivery:', DateFormat('MMM dd, yyyy HH:mm').format(order.proposedDeliveryTime!)),
                  if (order.pickupTime != null)
                    _buildDetailRow('Pickup Time:', DateFormat('MMM dd, yyyy HH:mm').format(order.pickupTime!)),
                  if (order.deliveryTime != null)
                    _buildDetailRow('Delivery Time:', DateFormat('MMM dd, yyyy HH:mm').format(order.deliveryTime!)),
                ]),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: widget),
        ],
      ),
    );
  }
}