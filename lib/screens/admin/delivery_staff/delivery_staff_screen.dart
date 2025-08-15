import 'package:flutter/material.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/delivery_staff_list.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/dialogue_components.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/header_widget.dart';
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
          
          // Quick action buttons
          _buildQuickActionButtons(context),
          const SizedBox(height: 16),
          
          // Staff list
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DeliveryStaffList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => DeliveryStaffDialogs.showSearchDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Search Staff'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => DeliveryStaffDialogs.showFilterDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => context.read<DeliveryPersonnelProvider>().fetchAvailableDeliveryPersonnel(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Available Only'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => context.read<DeliveryPersonnelProvider>().searchDeliveryPersonnel(isVerified: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.verified),
            label: const Text('Verified Only'),
          ),
        ],
      ),
    );
  }
}