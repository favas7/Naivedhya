import 'package:flutter/material.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class AssignDeliveryPartnerDialog extends StatefulWidget {
  final Order order;

  const AssignDeliveryPartnerDialog({
    super.key,
    required this.order,
  });

  @override
  State<AssignDeliveryPartnerDialog> createState() => _AssignDeliveryPartnerDialogState();
}

class _AssignDeliveryPartnerDialogState extends State<AssignDeliveryPartnerDialog> {
  bool _isAssigning = false;
  String? _selectedPartnerId;

  @override
  void initState() {
    super.initState();
    // Fetch available delivery partners when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryPersonnelProvider>().fetchAvailableDeliveryPersonnel();
    });
  }

  Future<void> _assignPartner(String partnerId, String partnerName) async {
    setState(() {
      _isAssigning = true;
      _selectedPartnerId = partnerId;
    });

    try {
      // Call assignment method
      final success = await context.read<OrderProvider>().assignDeliveryPartner(
        orderId: widget.order.orderId,
        deliveryPersonId: partnerId,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Assigned to $partnerName'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Close dialog
        Navigator.pop(context, true);

        // Refresh orders list
        context.read<OrderProvider>().refreshOrders();
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to assign delivery partner'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
          _selectedPartnerId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delivery_dining,
                    color: colors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Delivery Partner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${widget.order.orderNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colors.textSecondary),
                  ),
                ],
              ),
            ),

            // Order Info Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.textSecondary.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      colors,
                      Icons.person_outline,
                      widget.order.customerName ?? 'Customer',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      colors,
                      Icons.payments_outlined,
                      '₹${widget.order.totalAmount.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
            ),

            // Partners List
            Expanded(
              child: Consumer<DeliveryPersonnelProvider>(
                builder: (context, deliveryProvider, child) {
                  if (deliveryProvider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Loading available partners...',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  final availablePartners = deliveryProvider.availablePersonnel
                      .where((p) => p.isVerified)
                      .toList();

                  if (availablePartners.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.do_not_disturb_alt,
                            size: 64,
                            color: colors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Available Partners',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All delivery partners are currently busy',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availablePartners.length,
                    itemBuilder: (context, index) {
                      final partner = availablePartners[index];
                      final isAssigning = _isAssigning && 
                          _selectedPartnerId == partner.userId;

                      return _buildPartnerCard(
                        colors,
                        partner,
                        isAssigning,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(AppThemeColors colors, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(
    AppThemeColors colors,
    DeliveryPersonnel partner,
    bool isAssigning,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    partner.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Assign Button
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () => _assignPartner(partner.userId, partner.fullName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isAssigning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Assign',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  colors,
                  Icons.phone_outlined,
                  partner.phone,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  colors,
                  Icons.two_wheeler_outlined,
                  partner.vehicleType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  colors,
                  Icons.credit_card,
                  partner.numberPlate,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  colors,
                  Icons.delivery_dining,
                  '${partner.assignedOrders.length} orders',
                ),
              ),
            ],
          ),
          if (partner.earnings > 0) ...[
            const SizedBox(height: 8),
            _buildDetailItem(
              colors,
              Icons.payments_outlined,
              '₹${partner.earnings.toStringAsFixed(0)} earned',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(AppThemeColors colors, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}