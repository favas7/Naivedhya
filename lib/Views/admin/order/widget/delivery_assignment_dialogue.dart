// widgets/delivery_assignment_dialog.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/services/delivery_person_service.dart';

class DeliveryAssignmentDialog extends StatefulWidget {
  final Order order;
  final Function(String orderId, String deliveryPersonId) onAssignDelivery;

  const DeliveryAssignmentDialog({
    super.key,
    required this.order,
    required this.onAssignDelivery,
  });

  static Future<void> show(
    BuildContext context,
    Order order,
    Function(String orderId, String deliveryPersonId) onAssignDelivery,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DeliveryAssignmentDialog(
          order: order,
          onAssignDelivery: onAssignDelivery,
        );
      },
    );
  }

  @override
  State<DeliveryAssignmentDialog> createState() => _DeliveryAssignmentDialogState();
}

class _DeliveryAssignmentDialogState extends State<DeliveryAssignmentDialog> {
  final DeliveryPersonnelService _deliveryService = DeliveryPersonnelService();
  final TextEditingController _searchController = TextEditingController();
  
  List<SimpleDeliveryPersonnel> _availablePersonnel = []; // Updated type
  List<SimpleDeliveryPersonnel> _filteredPersonnel = []; // Updated type
  bool _isLoading = true;
  String? _error;
  String? _selectedDeliveryPersonId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPersonnel);
    _loadAvailablePersonnel();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPersonnel);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailablePersonnel() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final personnel = await _deliveryService.fetchAvailableDeliveryPersonnel();
      
      if (mounted) {
        setState(() {
          _availablePersonnel = personnel;
          _filteredPersonnel = personnel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterPersonnel() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersonnel = _availablePersonnel.where((person) {
        return person.name.toLowerCase().contains(query) ||
            person.fullName.toLowerCase().contains(query) ||
            person.phone.contains(query) ||
            person.vehicleType.toLowerCase().contains(query) ||
            person.numberPlate.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _assignDelivery() async {
    if (_selectedDeliveryPersonId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery person'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await widget.onAssignDelivery(widget.order.orderId, _selectedDeliveryPersonId!);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Close assignment dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery person assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign delivery person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Assign Delivery Person'),
          Text(
            'Order: ${widget.order.orderNumber}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search delivery personnel',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDeliveryPersonId != null ? _assignDelivery : null,
          child: const Text('Assign'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading delivery personnel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAvailablePersonnel,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPersonnel.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'No personnel match your search'
                  : 'No available delivery personnel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'All delivery personnel are currently busy or unavailable',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredPersonnel.length,
      itemBuilder: (context, index) {
        final person = _filteredPersonnel[index];
        final isSelected = _selectedDeliveryPersonId == person.userId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 3 : 1,
          child: RadioListTile<String>(
            value: person.userId,
            groupValue: _selectedDeliveryPersonId,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryPersonId = value;
              });
            },
            title: Text(
              person.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Phone: ${person.phone}'),
                Text('Vehicle: ${person.vehicleInfo}'),
                Text('Active Orders: ${person.activeOrdersCount}'),
                Text('Location: ${person.city}, ${person.state}'),
                const SizedBox(height: 4),
              ],
            ),
            secondary: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (person.isVerified)
                  const Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}