import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class EditOrderForm extends StatefulWidget {
  final Order order;
  final Function(Order) onOrderUpdated;
  final bool isMobile;

  const EditOrderForm({
    super.key,
    required this.order,
    required this.onOrderUpdated,
    required this.isMobile,
  });

  @override
  State<EditOrderForm> createState() => _EditOrderFormState();
}

class _EditOrderFormState extends State<EditOrderForm> {
  late TextEditingController customerNameController;
  late TextEditingController customerPhoneController;
  late TextEditingController customerAddressController;
  late TextEditingController totalAmountController;
  late TextEditingController specialInstructionsController;

  late String selectedStatus;
  late String selectedDeliveryStatus;
  late String selectedPaymentMethod;
  late DateTime? selectedDeliveryTime;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    customerNameController =
        TextEditingController(text: widget.order.customerName ?? '');
    customerPhoneController = TextEditingController(text: '');
    customerAddressController = TextEditingController(text: '');
    totalAmountController =
        TextEditingController(text: widget.order.totalAmount.toStringAsFixed(2));
    specialInstructionsController = TextEditingController(text: '');

    selectedStatus = widget.order.status.toLowerCase();
    selectedDeliveryStatus = widget.order.deliveryStatus ?? 'Pending';
    selectedPaymentMethod = 'Cash';
    selectedDeliveryTime = widget.order.proposedDeliveryTime;
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerAddressController.dispose();
    totalAmountController.dispose();
    specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeliveryTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          selectedDeliveryTime ?? DateTime.now(),
        ),
      );

      if (time != null) {
        setState(() {
          selectedDeliveryTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Create updated order
      final updatedOrder = Order(
        orderId: widget.order.orderId,
        orderNumber: widget.order.orderNumber,
        customerId: widget.order.customerId,
        customerName: customerNameController.text,
        restaurantId: widget.order.restaurantId,
        vendorId: widget.order.vendorId,
        status: selectedStatus,
        totalAmount: double.parse(totalAmountController.text),
        deliveryStatus: selectedDeliveryStatus,
        deliveryPersonId: widget.order.deliveryPersonId,
        proposedDeliveryTime: selectedDeliveryTime,
        pickupTime: widget.order.pickupTime,
        deliveryTime: widget.order.deliveryTime,
        createdAt: widget.order.createdAt,
        updatedAt: DateTime.now(),
      );

      // TODO: Call API to update order
      // await orderRepository.updateOrder(updatedOrder);

      widget.onOrderUpdated(updatedOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order updated successfully'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information Section
            _buildSectionHeader('Customer Information', themeColors),
            SizedBox(height: 12.h),
            _buildTextFormField(
              controller: customerNameController,
              label: 'Customer Name',
              icon: Icons.person,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              themeColors: themeColors,
            ),
            SizedBox(height: 12.h),
            _buildTextFormField(
              controller: customerAddressController,
              label: 'Delivery Address',
              icon: Icons.location_on,
              maxLines: 2,
              themeColors: themeColors,
            ),
            SizedBox(height: 24.h),

            // Order Amount Section
            _buildSectionHeader('Order Amount', themeColors),
            SizedBox(height: 12.h),
            _buildTextFormField(
              controller: totalAmountController,
              label: 'Total Amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
                return null;
              },
              themeColors: themeColors,
            ),
            SizedBox(height: 24.h),

            // Payment Method Section
            _buildSectionHeader('Payment Method', themeColors),
            SizedBox(height: 12.h),
            _buildDropdownField(
              label: 'Payment Method',
              value: selectedPaymentMethod,
              items: ['Cash', 'Online', 'Card'],
              onChanged: (value) {
                setState(() => selectedPaymentMethod = value ?? 'Cash');
              },
              themeColors: themeColors,
            ),
            SizedBox(height: 24.h),

            // Order Status Section
            _buildSectionHeader('Order Status', themeColors),
            SizedBox(height: 12.h),
            _buildDropdownField(
              label: 'Order Status',
              value: selectedStatus,
              items: [
                'pending',
                'confirmed',
                'preparing',
                'ready',
                'picked up',
                'delivering',
                'completed',
                'cancelled',
              ],
              onChanged: (value) {
                setState(() => selectedStatus = value ?? 'pending');
              },
              themeColors: themeColors,
            ),
            SizedBox(height: 24.h),

            // Delivery Information Section
            _buildSectionHeader('Delivery Information', themeColors),
            SizedBox(height: 12.h),
            _buildDropdownField(
              label: 'Delivery Status',
              value: selectedDeliveryStatus,
              items: ['Pending', 'On the Way', 'Delivered', 'Failed'],
              onChanged: (value) {
                setState(() => selectedDeliveryStatus = value ?? 'Pending');
              },
              themeColors: themeColors,
            ),
            SizedBox(height: 12.h),
            _buildDateTimeField(
              label: 'Delivery Time',
              dateTime: selectedDeliveryTime,
              onTap: _selectDeliveryTime,
              themeColors: themeColors,
            ),
            SizedBox(height: 24.h),

            // Special Instructions Section
            _buildSectionHeader('Special Instructions', themeColors),
            SizedBox(height: 12.h),
            _buildTextFormField(
              controller: specialInstructionsController,
              label: 'Add special instructions',
              icon: Icons.note,
              maxLines: 3,
              themeColors: themeColors,
            ),
            SizedBox(height: 32.h),

            // Action Buttons
            _buildActionButtons(themeColors),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppThemeColors themeColors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: themeColors.textPrimary,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    required AppThemeColors themeColors,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: themeColors.primary,
            width: 2,
          ),
        ),
        fillColor: themeColors.surface,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required AppThemeColors themeColors,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: themeColors.primary,
            width: 2,
          ),
        ),
        fillColor: themeColors.surface,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
    required AppThemeColors themeColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: themeColors.isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          color: themeColors.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: themeColors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: themeColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateTime != null
                        ? DateFormat('dd/MM/yyyy hh:mm a').format(dateTime)
                        : 'Select date and time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: themeColors.textPrimary,
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

  Widget _buildActionButtons(AppThemeColors themeColors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return isSmallScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Order',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  SizedBox(height: 8.h),
                  OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(
                        color: themeColors.textSecondary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: themeColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: themeColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Update Order',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}