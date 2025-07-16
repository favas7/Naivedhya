import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
          Text(
            'Orders Management',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSearchBar(context, isDesktop),
                    const SizedBox(height: 16),
                    _buildOrdersTable(context, isDesktop),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDesktop) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search orders...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildOrdersTable(BuildContext context, bool isDesktop) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            10,
            (index) => DataRow(cells: [
              DataCell(Text('#${1000 + index}')),
              DataCell(Text('Customer ${index + 1}')),
              DataCell(Text('2025-07-${14 - index}')),
              DataCell(Text('Pending')),
              DataCell(Text('\$${(index + 1) * 25.99}')),
              DataCell(IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              )),
            ]),
          ),
        ),
      ),
    );
  }
}