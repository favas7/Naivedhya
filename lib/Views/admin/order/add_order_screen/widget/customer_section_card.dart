// lib/Views/admin/order/add_order_screen/widget/customer_section_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/address_selector_dropdown.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/customer_info_display.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/models/address_model.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomerSectionCard extends StatelessWidget {
  final UserModel? selectedCustomer;
  final bool isGuestOrder;
  final String? guestName;
  final String? guestMobile;
  final String? guestAddress;
  final List<Address> customerAddresses;
  final Address? selectedAddress;
  final VoidCallback onSelectCustomer;
  final ValueChanged<Address?> onAddressChanged;

  const CustomerSectionCard({
    super.key,
    required this.selectedCustomer,
    required this.isGuestOrder,
    this.guestName,
    this.guestMobile,
    this.guestAddress,
    required this.customerAddresses,
    required this.selectedAddress,
    required this.onSelectCustomer,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final _ = AppTheme.of(context);

    return SectionCardWrapper(
      title: 'Customer',
      icon: Icons.person,
      trailing: ElevatedButton.icon(
        onPressed: onSelectCustomer,
        icon: const Icon(Icons.person_add, size: 16),
        label: const Text('Select'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerInfoDisplay(
            customer: selectedCustomer,
            isGuestOrder: isGuestOrder,
            guestName: guestName,
            guestMobile: guestMobile,
            guestAddress: guestAddress,
          ),
          
          if (selectedCustomer != null && customerAddresses.isNotEmpty) ...[
            const SizedBox(height: 16),
            AddressSelectorDropdown(
              addresses: customerAddresses,
              selectedAddress: selectedAddress,
              onAddressChanged: onAddressChanged,
            ),
          ],
        ],
      ),
    );
  }
}