import 'package:flutter/material.dart';
import 'package:naivedhya/models/payment_model.dart';
import 'package:naivedhya/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 20;
  PaymentStatus? _statusFilter;
  PaymentMode? _modeFilter;
  Timer? _searchTimer;
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _setupRealTimeSubscription();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    _subscription?.unsubscribe();
    super.dispose();
  }

  void _setupRealTimeSubscription() {
    _subscription = _paymentService.subscribeToPayments((updatedPayments) {
      if (mounted) {
        setState(() {
          _payments = updatedPayments;
        });
      }
    });
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadPayments(resetPage: true);
    });
  }

  Future<void> _loadPayments({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final searchQuery = _searchController.text.trim();
      
      final [payments, totalCount] = await Future.wait([
        _paymentService.getPayments(
          page: _currentPage,
          limit: _limit,
          searchQuery: searchQuery.isEmpty ? null : searchQuery,
          statusFilter: _statusFilter,
          modeFilter: _modeFilter,
        ),
        _paymentService.getPaymentsCount(
          searchQuery: searchQuery.isEmpty ? null : searchQuery,
          statusFilter: _statusFilter,
          modeFilter: _modeFilter,
        ),
      ]);

      setState(() {
        _payments = payments as List<Payment>;
        _totalCount = totalCount as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      await _paymentService.updatePaymentStatus(paymentId, status);
      _loadPayments(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
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
          Text(
            'Payments Management',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildFiltersRow(context, isDesktop),
          const SizedBox(height: 16),
          _buildSearchBar(context, isDesktop),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(context, isDesktop),
              ),
            ),
          ),
          if (_totalCount > _limit) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<PaymentStatus?>(
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _statusFilter,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...PaymentStatus.values.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.value),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
              _loadPayments(resetPage: true);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<PaymentMode?>(
            decoration: const InputDecoration(
              labelText: 'Filter by Mode',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _modeFilter,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Modes')),
              ...PaymentMode.values.map(
                (mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode.value),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _modeFilter = value;
              });
              _loadPayments(resetPage: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDesktop) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by Payment ID, Order ID, Customer ID, or Transaction ID...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading payments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Try adjusting your search or filters'),
          ],
        ),
      );
    }

    return _buildPaymentsTable(context, isDesktop);
  }

  Widget _buildPaymentsTable(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Payment ID')),
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Mode')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _payments.map((payment) => DataRow(
            cells: [
              DataCell(
                Text(
                  payment.paymentId.length > 8 
                      ? '${payment.paymentId.substring(0, 8)}...'
                      : payment.paymentId,
                ),
              ),
              DataCell(
                Text(
                  payment.orderId.length > 8 
                      ? '${payment.orderId.substring(0, 8)}...'
                      : payment.orderId,
                ),
              ),
              DataCell(Text(payment.customerName)),
              DataCell(Text(payment.formattedAmount)),
              DataCell(
                Chip(
                  label: Text(
                    payment.paymentMode.value,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getPaymentModeColor(payment.paymentMode),
                ),
              ),
              DataCell(
                Chip(
                  label: Text(
                    payment.status.value,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(payment.status),
                ),
              ),
              DataCell(Text(payment.formattedDate)),
              DataCell(
                PopupMenuButton<PaymentStatus>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (status) {
                    _updatePaymentStatus(payment.paymentId, status);
                  },
                  itemBuilder: (context) => PaymentStatus.values
                      .where((status) => status != payment.status)
                      .map(
                        (status) => PopupMenuItem(
                          value: status,
                          child: Text('Mark as ${status.value}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = (_totalCount / _limit).ceil();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing ${(_currentPage - 1) * _limit + 1}-${_currentPage * _limit > _totalCount ? _totalCount : _currentPage * _limit} of $_totalCount'),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadPayments();
                } : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Page $_currentPage of $totalPages'),
              IconButton(
                onPressed: _currentPage < totalPages ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadPayments();
                } : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return Colors.blue[100]!;
      case PaymentMode.cashOnDelivery:
        return Colors.green[100]!;
      case PaymentMode.wallet:
        return Colors.purple[100]!;
    }
  }
}