// screens/order_detail_dialog.dart - REFACTORED WITH EXTRACTED WIDGETS

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/Views/admin/order/widget/order_detail_item.dart';
import 'package:naivedhya/Views/admin/order/widget/order_detail_section.dart'; 
import 'package:naivedhya/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/services/ventor_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/services/restaurant_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late RestaurantService _restaurantService;
  late VendorService _vendorService;

  Map<String, dynamic>? _restaurantDetails;
  Map<String, dynamic>? _vendorDetails;
  bool _isLoadingDetails = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _restaurantService = RestaurantService();
    _vendorService = VendorService();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });

      // Fetch restaurant and vendor details in parallel
      final restaurantFuture =
          _restaurantService.getRestaurantById(widget.order.restaurantId);
      final vendorFuture =
          _vendorService.fetchVendorById(widget.order.vendorId);

      final results = await Future.wait([restaurantFuture, vendorFuture]);

      if (mounted) {
        setState(() {
          _restaurantDetails = results[0] != null
              ? (results[0] as Map<String, dynamic>)
              : null;
          _vendorDetails = results[1] as Map<String, dynamic>?;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('Error loading details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load order details: $e';
          _isLoadingDetails = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);
    final statusColor =
        AppTheme.getOrderStatusColor(widget.order.status, themeColors.isDark);
    final statusBgColor =
        AppTheme.getOrderStatusBgColor(widget.order.status, themeColors.isDark);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.all(16.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: themeColors.surface,
        ),
        child: Column(
          children: [
            // Header with Status
            _buildHeader(themeColors, statusColor, statusBgColor),

            // Details Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _isLoadingDetails
                    ? _buildLoadingState(themeColors)
                    : _errorMessage != null
                        ? _buildErrorState(themeColors)
                        : _buildDetailsContent(themeColors),
              ),
            ),

            // Action Buttons Footer
            _buildFooter(themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors themeColors, Color statusColor,
      Color statusBgColor) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusBgColor,
            statusBgColor.withAlpha(220),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.order.orderNumber}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: themeColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(100),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: themeColors.textPrimary,
                  size: 24.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppThemeColors themeColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading order details...',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppThemeColors themeColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Details',
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: _loadDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsContent(AppThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Section
        OrderDetailSection(
          title: 'Customer Information',
          icon: Icons.person_outline,
          themeColors: themeColors,
          children: [
            OrderDetailItem(
              label: 'Name',
              value: widget.order.customerName ?? 'Guest',
              themeColors: themeColors,
              icon: Icons.account_circle_outlined,
            ),
            SizedBox(height: 12.h),
            OrderDetailItem(
              label: 'Customer ID',
              value: widget.order.customerId ?? 'N/A',
              themeColors: themeColors,
              icon: Icons.badge_outlined,
            ),
          ],
        ),
        SizedBox(height: 18.h),

        // Order Details Section
        OrderDetailSection(
          title: 'Order Details',
          icon: Icons.receipt_outlined,
          themeColors: themeColors,
          children: [
            OrderDetailItem(
              label: 'Total Amount',
              value: '₹${widget.order.totalAmount.toStringAsFixed(2)}',
              themeColors: themeColors,
              icon: Icons.currency_rupee,
              isHighlight: true,
            ),
            SizedBox(height: 12.h),
            OrderDetailItem(
              label: 'Restaurant',
              value: _restaurantDetails?['name'] ?? widget.order.restaurantId,
              themeColors: themeColors,
              icon: Icons.restaurant_outlined,
            ),
            SizedBox(height: 12.h),
            OrderDetailItem(
              label: 'Vendor',
              value: _vendorDetails?['name'] ?? widget.order.vendorId,
              themeColors: themeColors,
              icon: Icons.store_outlined,
            ),
            SizedBox(height: 12.h),
            OrderDetailItem(
              label: 'Order Number',
              value: widget.order.orderNumber,
              themeColors: themeColors,
              icon: Icons.tag_outlined,
            ),
          ],
        ),
        SizedBox(height: 18.h),

        // Delivery Section
        OrderDetailSection(
          title: 'Delivery Information',
          icon: Icons.local_shipping_outlined,
          themeColors: themeColors,
          children: [
            OrderDetailItem(
              label: 'Delivery Status',
              value: widget.order.deliveryStatus ?? 'Not Assigned',
              themeColors: themeColors,
              icon: Icons.info_outlined,
            ),
            if (widget.order.proposedDeliveryTime != null) ...[
              SizedBox(height: 12.h),
              OrderDetailItem(
                label: 'Proposed Delivery Time',
                value: _formatDate(widget.order.proposedDeliveryTime),
                themeColors: themeColors,
                icon: Icons.schedule_outlined,
              ),
            ],
            if (widget.order.pickupTime != null) ...[
              SizedBox(height: 12.h),
              OrderDetailItem(
                label: 'Pickup Time',
                value: _formatDate(widget.order.pickupTime),
                themeColors: themeColors,
                icon: Icons.location_on_outlined,
              ),
            ],
            if (widget.order.deliveryTime != null) ...[
              SizedBox(height: 12.h),
              OrderDetailItem(
                label: 'Delivery Time',
                value: _formatDate(widget.order.deliveryTime),
                themeColors: themeColors,
                icon: Icons.check_circle_outline,
              ),
            ],
            if (widget.order.deliveryPersonId != null) ...[
              SizedBox(height: 12.h),
              OrderDetailItem(
                label: 'Delivery Person ID',
                value: widget.order.deliveryPersonId!,
                themeColors: themeColors,
                icon: Icons.person_outline,
              ),
            ],
          ],
        ),
        SizedBox(height: 18.h),

        // Timestamps Section
        OrderDetailSection(
          title: 'Record Information',
          icon: Icons.history_outlined,
          themeColors: themeColors,
          children: [
            OrderDetailItem(
              label: 'Created At',
              value: _formatDate(widget.order.createdAt),
              themeColors: themeColors,
              icon: Icons.add_circle_outline,
            ),
            SizedBox(height: 12.h),
            OrderDetailItem(
              label: 'Updated At',
              value: _formatDate(widget.order.updatedAt),
              themeColors: themeColors,
              icon: Icons.edit_calendar_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(AppThemeColors themeColors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: themeColors.isDark
                ? Colors.grey[700]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Copy order details to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order details copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.content_copy),
              label: const Text('Copy'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}