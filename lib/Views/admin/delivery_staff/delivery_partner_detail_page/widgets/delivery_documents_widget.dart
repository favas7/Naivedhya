// views/admin/delivery_staff/widgets/delivery_documents_widget.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DeliveryDocumentsWidget extends StatelessWidget {
  final DeliveryPersonnel deliveryPerson;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;

  const DeliveryDocumentsWidget({
    super.key,
    required this.deliveryPerson,
    this.onVerify,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentCard(
            context,
            colors,
            'Driving License',
            Icons.credit_card,
            deliveryPerson.licenseImageUrl,
          ),
          const SizedBox(height: 24),
          _buildDocumentCard(
            context,
            colors,
            'Aadhaar Card',
            Icons.badge,
            deliveryPerson.aadhaarImageUrl,
          ),
          const SizedBox(height: 32),
          _buildVerificationSection(context, colors),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    AppThemeColors colors,
    String title,
    IconData icon,
    String? imageUrl,
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
          // Header
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _showFullImage(context, imageUrl, title),
                    icon: const Icon(Icons.fullscreen, size: 18),
                    label: const Text('View Full'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                    ),
                  ),
              ],
            ),
          ),

          // Document Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            InkWell(
              onTap: () => _showFullImage(context, imageUrl, title),
              child: Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: colors.background,
                      child: Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colors.error.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: colors.error),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: colors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.textSecondary.withOpacity(0.2),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: colors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No document uploaded',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(BuildContext context, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getVerificationColor(colors).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getVerificationIcon(),
                color: _getVerificationColor(colors),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getVerificationColor(colors).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getVerificationColor(colors).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        deliveryPerson.verificationStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getVerificationColor(colors),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!deliveryPerson.isVerified &&
              deliveryPerson.verificationStatus.toLowerCase() == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Verify Documents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            )
          else if (deliveryPerson.isVerified)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: colors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This delivery partner has been verified',
                      style: TextStyle(
                        color: colors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verification has been rejected',
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVerificationColor(AppThemeColors colors) {
    switch (deliveryPerson.verificationStatus.toLowerCase()) {
      case 'verified':
        return colors.success;
      case 'rejected':
        return colors.error;
      default:
        return colors.warning;
    }
  }

  IconData _getVerificationIcon() {
    switch (deliveryPerson.verificationStatus.toLowerCase()) {
      case 'verified':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}