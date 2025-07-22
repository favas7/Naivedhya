// screens/customer_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/screens/admin/customer/customer_dialogs.dart';
import 'package:naivedhya/screens/admin/customer/widgets/customer_loading_widget.dart';
import 'package:naivedhya/screens/admin/customer/widgets/customer_search_widget.dart';
import 'package:naivedhya/screens/admin/customer/widgets/customer_stats_widget.dart';
import 'package:naivedhya/screens/admin/customer/widgets/customer_table_widget.dart';
import 'package:naivedhya/services/customer_service.dart';


class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _customers = [];
  List<UserModel> _filteredCustomers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((customer) {
          return customer.name.toLowerCase().contains(query.toLowerCase()) ||
                 customer.email.toLowerCase().contains(query.toLowerCase()) ||
                 (customer.userid ?? '').toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterCustomers('');
  }

  void _showEditDialog(UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(
        customer: Customer.fromUserModel(customer),
        onCustomerUpdated: (updatedCustomer) {
          final updatedUserModel = updatedCustomer.toUserModel(customer);
          setState(() {
            final index = _customers.indexWhere((c) => c.id == updatedUserModel.id);
            if (index != -1) {
              _customers[index] = updatedUserModel;
              _filterCustomers(_searchController.text);
            }
          });
        },
      ),
    );
  }

  Future<void> _deleteCustomer(UserModel customer) async {
    final confirmed = await CustomerDialogs.showDeleteConfirmation(
      context: context,
      customer: customer,
    );

    if (confirmed == true && mounted) {
      try {
        await _customerService.deleteCustomer(customer.id ?? '');
        setState(() {
          _customers.removeWhere((c) => c.id == customer.id);
          _filterCustomers(_searchController.text);
        });
        
        if (mounted) {
          CustomerDialogs.showSuccessSnackbar(
            context: context,
            message: 'Customer deleted successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          CustomerDialogs.showErrorSnackbar(
            context: context,
            message: 'Failed to delete customer: ${e.toString()}',
          );
        }
      }
    }
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
          _buildHeader(isDesktop),
          const SizedBox(height: 16),
          if (!_isLoading) 
            CustomerStatsWidget(
              customers: _customers,
              isDesktop: isDesktop,
            ),
          const SizedBox(height: 24),
          CustomerSearchWidget(
            controller: _searchController,
            onChanged: _filterCustomers,
            onClear: _clearSearch,
            isDesktop: isDesktop,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Customers Management',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _loadCustomers,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildContent(bool isDesktop) {
    if (_isLoading) {
      return const CustomerLoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return CustomerErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _loadCustomers,
      );
    }

    if (_filteredCustomers.isEmpty) {
      return CustomerEmptyWidget(
        searchQuery: _searchController.text,
      );
    }

    return CustomerTableWidget(
      customers: _filteredCustomers,
      onEdit: _showEditDialog,
      onDelete: _deleteCustomer,
      isDesktop: isDesktop,
    );
  }
}