// lib/Views/admin/order/add_order_screen/widgets/order_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/order_item_model.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/models/ventor_model.dart';

class OrderConfirmationDialog {
  static void show({
    required BuildContext context,
    required Restaurant restaurant,
    required Vendor vendor,
    required Customer? customer,
    required String? customerName,
    required String? customerPhone,
    required String? deliveryAddress,
    required DateTime? proposedDeliveryTime,
    required List<OrderItem> orderItems,
    required double totalAmount,
    required String specialInstructions,
    required String paymentMethod,
    required VoidCallback onConfirm,
    required VoidCallback onEdit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OrderConfirmationDialogContent(
        restaurant: restaurant,
        vendor: vendor,
        customer: customer,
        customerName: customerName,
        customerPhone: customerPhone,
        deliveryAddress: deliveryAddress,
        proposedDeliveryTime: proposedDeliveryTime,
        orderItems: orderItems,
        totalAmount: totalAmount,
        specialInstructions: specialInstructions,
        paymentMethod: paymentMethod,
        onConfirm: onConfirm,
        onEdit: onEdit,
      ),
    );
  }
}

class _OrderConfirmationDialogContent extends StatelessWidget {
  final Restaurant restaurant;
  final Vendor vendor;
  final Customer? customer;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final DateTime? proposedDeliveryTime;
  final List<OrderItem> orderItems;
  final double totalAmount;
  final String specialInstructions;
  final String paymentMethod;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const _OrderConfirmationDialogContent({
    required this.restaurant,
    required this.vendor,
    required this.customer,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.proposedDeliveryTime,
    required this.orderItems,
    required this.totalAmount,
    required this.specialInstructions,
    required this.paymentMethod,
    required this.onConfirm,
    required this.onEdit,
  });

  String get _displayCustomerName {
    return customer?.name ?? customerName ?? 'Guest Customer';
  }

  String get _displayCustomerPhone {
    return customer?.phone ?? customerPhone ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
          maxWidth: isMobile ? double.infinity : 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirm Order',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Please review the order details before proceeding',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant & Vendor Info
                    _buildSectionHeader('Restaurant & Vendor'),
                    _buildInfoRow('Restaurant', restaurant.name),
                    _buildInfoRow('Vendor', vendor.name),
                    const SizedBox(height: 20),

                    // Customer Information
                    _buildSectionHeader('Customer Information'),
                    _buildInfoRow('Name', _displayCustomerName),
                    _buildInfoRow('Phone', _displayCustomerPhone),
                    if (deliveryAddress != null && deliveryAddress!.isNotEmpty)
                      _buildInfoRow(
                        'Delivery Address',
                        deliveryAddress!,
                        isMultiline: true,
                      ),
                    const SizedBox(height: 20),

                    // Order Items
                    _buildSectionHeader('Order Items'),
                    _buildOrderItemsList(),
                    const SizedBox(height: 20),

                    // Delivery & Payment Info
                    _buildSectionHeader('Delivery & Payment'),
                    if (proposedDeliveryTime != null)
                      _buildInfoRow(
                        'Proposed Delivery Time',
                        _formatDateTime(proposedDeliveryTime!),
                      ),
                    _buildInfoRow('Payment Method', paymentMethod),
                    const SizedBox(height: 20),

                    // Special Instructions
                    if (specialInstructions.isNotEmpty) ...[
                      _buildSectionHeader('Special Instructions'),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          border: Border.all(color: Colors.amber[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          specialInstructions,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Price Breakdown
                    _buildPriceBreakdown(),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEdit();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Order'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm & Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ...orderItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildOrderItemTile(item, index);
          }),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: index > 0 ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.itemName} × ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (item.selectedCustomizations.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...item.selectedCustomizations.map((custom) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '  • ${custom.customizationName}: ${custom.selectedOptionName}${custom.additionalPrice > 0 ? ' (+₹${custom.additionalPrice.toStringAsFixed(2)})' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final baseTotal = orderItems.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    final customizationTotal = orderItems.fold<double>(
      0,
      (sum, item) => sum + (item.customizationAdditionalPrice * item.quantity),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Items Subtotal', '₹${baseTotal.toStringAsFixed(2)}'),
          if (customizationTotal > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Customizations', '₹${customizationTotal.toStringAsFixed(2)}', isSubtotal: true),
          ],
          const Divider(height: 16),
          _buildPriceRow(
            'Total Amount',
            '₹${totalAmount.toStringAsFixed(2)}',
            isBold: true,
            isLarge: true,
            color: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSubtotal = false,
    bool isLarge = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 15 : 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}