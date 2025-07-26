import 'package:flutter/material.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/dialogue_components.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/header_widget.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/staff_list_widget.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';


class DeliveryStaffScreen extends StatefulWidget {
  const DeliveryStaffScreen({super.key});

  @override
  State<DeliveryStaffScreen> createState() => _DeliveryStaffScreenState();
}

class _DeliveryStaffScreenState extends State<DeliveryStaffScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch delivery personnel when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and stats
          DeliveryStaffHeader(isDesktop: isDesktop),
          const SizedBox(height: 24),
          
          // Add new staff button
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ElevatedButton.icon(
                onPressed: () => DeliveryStaffDialogs.showAddStaffDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add New Staff'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Staff list
          const Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: DeliveryStaffList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}