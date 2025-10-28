// views/admin/delivery_staff/widgets/delivery_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:intl/intl.dart';

class DeliveryInfoCard extends StatelessWidget {
  final DeliveryPersonnel deliveryPerson;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleAvailability;

  const DeliveryInfoCard({
    super.key,
    required this.deliveryPerson,
    this.onEdit,
    this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          colors,
          'Personal Information',
          Icons.person,
          [
            _buildInfoRow(colors, 'Full Name', deliveryPerson.fullName),
            _buildInfoRow(colors, 'Display Name', deliveryPerson.displayName),
            _buildInfoRow(colors, 'Email', deliveryPerson.email, copyable: true),
            _buildInfoRow(colors, 'Phone', deliveryPerson.phone, copyable: true),
            _buildInfoRow(
              colors,
              'Date of Birth',
              DateFormat('dd MMM yyyy').format(deliveryPerson.dateOfBirth),
            ),
            _buildInfoRow(colors, 'Age', '${deliveryPerson.age} years'),
            _buildInfoRow(colors, 'Aadhaar Number', _maskAadhaar(deliveryPerson.aadhaarNumber)),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          colors,
          'Location',
          Icons.location_on,
          [
            _buildInfoRow(colors, 'City', deliveryPerson.city),
            _buildInfoRow(colors, 'State', deliveryPerson.state),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          colors,
          'Vehicle Information',
          Icons.directions_car,
          [
            _buildInfoRow(colors, 'Vehicle Type', deliveryPerson.vehicleType),
            _buildInfoRow(colors, 'Vehicle Model', deliveryPerson.vehicleModel),
            _buildInfoRow(colors, 'Number Plate', deliveryPerson.numberPlate, copyable: true),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          colors,
          'Status & Verification',
          Icons.verified_user,
          [
            _buildStatusRow(colors, 'Availability', deliveryPerson.isAvailable),
            _buildStatusRow(colors, 'Verified', deliveryPerson.isVerified),
            _buildInfoRow(colors, 'Verification Status', deliveryPerson.verificationStatus),
            _buildInfoRow(colors, 'Active Orders', deliveryPerson.activeOrdersCount.toString()),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          colors,
          'Account Information',
          Icons.calendar_today,
          [
            _buildInfoRow(
              colors,
              'User ID',
              deliveryPerson.userId,
              copyable: true,
            ),
            _buildInfoRow(
              colors,
              'Joined',
              DateFormat('dd MMM yyyy, HH:mm').format(deliveryPerson.createdAt),
            ),
            _buildInfoRow(
              colors,
              'Last Updated',
              DateFormat('dd MMM yyyy, HH:mm').format(deliveryPerson.updatedAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    AppThemeColors colors,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    AppThemeColors colors,
    String label,
    String value, {
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'N/A' : value,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (copyable)
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      // Show snackbar (requires context, skipped for brevity)
                    },
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    tooltip: 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    AppThemeColors colors,
    String label,
    bool status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status
                        ? colors.success.withOpacity(0.1)
                        : colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status
                          ? colors.success.withOpacity(0.3)
                          : colors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: status ? colors.success : colors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status ? 'Yes' : 'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: status ? colors.success : colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length < 4) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }
}