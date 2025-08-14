// widgets/order_details_dialog.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart'; 
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/screens/admin/order/widget/order_status.dart';
import 'package:naivedhya/services/delivery_person_service.dart';

class OrderDetailsDialog extends StatefulWidget {
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
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  SimpleDeliveryPersonnel? _deliveryPersonnel;
  bool _loadingDeliveryInfo = false;

  @override
  void initState() {
    super.initState();
    if (widget.order.deliveryPersonId != null) {
      _loadDeliveryPersonnelInfo();
    }
  }

  Future<void> _loadDeliveryPersonnelInfo() async {
    if (widget.order.deliveryPersonId == null) return;

    setState(() {
      _loadingDeliveryInfo = true;
    });

    try {
      // Using the correct method name from the service
      final personnel = await _deliveryService.fetchDeliveryPersonnelById(
        widget.order.deliveryPersonId!,
      );
      setState(() {
        _deliveryPersonnel = personnel;
        _loadingDeliveryInfo = false;
      });
    } catch (e) {
      setState(() {
        _loadingDeliveryInfo = false;
      });
      debugPrint('Error loading delivery personnel: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Order Details - ${widget.order.orderNumber}',
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
              // Basic Order Information
              _buildDetailCard('Order Information', [
                _buildDetailRow('Order ID:', widget.order.orderNumber),
                _buildDetailRow('Customer:', widget.order.customerName ?? 'Unknown'),
                _buildDetailRow('Customer ID:', widget.order.customerId),
                _buildDetailRow('Vendor ID:', widget.order.vendorId),
                _buildDetailRow('Hotel ID:', widget.order.hotelId),
              ]),
              const SizedBox(height: 16),

              // Status Information
              _buildDetailCard('Status Information', [
                _buildDetailRowWithWidget('Order Status:', OrderStatusChip(status: widget.order.status)),
                _buildDetailRowWithWidget(
                  'Delivery Status:',
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDeliveryStatusColor(widget.order.deliveryStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.order.deliveryStatus ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Delivery Personnel Information
              if (widget.order.deliveryPersonId != null) ...[
                _buildDeliveryPersonnelCard(),
                const SizedBox(height: 16),
              ],

              // Financial Information
              _buildDetailCard('Financial Information', [
                _buildDetailRow('Total Amount:', '\$${widget.order.totalAmount.toStringAsFixed(2)}'),
                _buildDetailRow('Order Date:', DateFormat('MMM dd, yyyy HH:mm').format(widget.order.createdAt)),
                _buildDetailRow('Last Updated:', DateFormat('MMM dd, yyyy HH:mm').format(widget.order.updatedAt)),
              ]),

              // Timeline Information
              if (widget.order.proposedDeliveryTime != null || 
                  widget.order.pickupTime != null || 
                  widget.order.deliveryTime != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard('Timeline', [
                  if (widget.order.proposedDeliveryTime != null)
                    _buildDetailRow('Proposed Delivery:', DateFormat('MMM dd, yyyy HH:mm').format(widget.order.proposedDeliveryTime!)),
                  if (widget.order.pickupTime != null)
                    _buildDetailRow('Pickup Time:', DateFormat('MMM dd, yyyy HH:mm').format(widget.order.pickupTime!)),
                  if (widget.order.deliveryTime != null)
                    _buildDetailRow('Delivery Time:', DateFormat('MMM dd, yyyy HH:mm').format(widget.order.deliveryTime!)),
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

  Widget _buildDeliveryPersonnelCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.delivery_dining, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Personnel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_loadingDeliveryInfo)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_deliveryPersonnel != null) ...[
              _buildDetailRow('Name:', _deliveryPersonnel!.displayName),
              _buildDetailRow('Phone:', _deliveryPersonnel!.phone),
              _buildDetailRow('Email:', _deliveryPersonnel!.email),
              _buildDetailRow('Vehicle:', _deliveryPersonnel!.vehicleInfo),
              _buildDetailRow('Location:', '${_deliveryPersonnel!.city}, ${_deliveryPersonnel!.state}'),
              _buildDetailRow('Active Orders:', _deliveryPersonnel!.activeOrdersCount.toString()),
              _buildDetailRow('Earnings:', '\$${_deliveryPersonnel!.earnings.toStringAsFixed(2)}'),
              _buildDetailRowWithWidget(
                'Status:',
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _deliveryPersonnel!.isAvailable ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_deliveryPersonnel!.isAvailable ? 'Available' : 'Busy'),
                    if (_deliveryPersonnel!.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
              _buildDetailRow('Verification:', _deliveryPersonnel!.verificationStatus.toUpperCase()),
              _buildDetailRow('Member Since:', DateFormat('MMM dd, yyyy').format(_deliveryPersonnel!.createdAt)),
            ] else ...[
              _buildDetailRow('Personnel ID:', widget.order.deliveryPersonId ?? 'Unknown'),
              const Text(
                'Detailed information could not be loaded',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),
            ...children,
          ],
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