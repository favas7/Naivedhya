// widgets/order_filters_widget.dart
import 'package:flutter/material.dart';

class OrderFiltersWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final List<String> statusOptions;
  final Function(String) onStatusChanged;
  final VoidCallback onRefresh;

  const OrderFiltersWidget({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Column(
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSearchField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusDropdown(),
              ),
              const SizedBox(width: 16),
              _buildRefreshButton(),
            ],
          )
        else
          Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildStatusDropdown(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildRefreshButton(),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search orders by ID, customer, or status...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      isExpanded: true, // This prevents overflow by allowing text to expand
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            overflow: TextOverflow.ellipsis, // Handle long text
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onStatusChanged(value);
        }
      },
    );
  }

  Widget _buildRefreshButton() {
    return ElevatedButton.icon(
      onPressed: onRefresh,
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
      style: ElevatedButton.styleFrom(
        // Make button more compact on mobile
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}