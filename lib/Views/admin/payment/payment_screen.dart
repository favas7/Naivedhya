import 'dart:async';
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/payment/widgets/payment_card.dart';
import 'package:naivedhya/models/payment_model.dart';
import 'package:naivedhya/services/payment_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Payment> _payments = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String? _error;
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 20;
  PaymentStatus? _statusFilter;
  PaymentMode? _modeFilter;
  String _quickFilter = 'all'; // all, today, week, month
  Timer? _searchTimer;
  RealtimeChannel? _subscription;

  // Stats
  double _totalAmount = 0;
  int _completedPayments = 0;
  int _pendingPayments = 0;
  int _failedPayments = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _loadStats();
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
        setState(() => _payments = updatedPayments);
        _loadStats();
      }
    });
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadPayments(resetPage: true);
    });
  }

  Future<void> _loadStats() async {
    try {
      final summary = await _paymentService.getPaymentsSummary();
      if (mounted) {
        setState(() {
          _totalAmount = (summary['total_amount'] ?? 0).toDouble();
          _completedPayments = summary['completed_payments'] ?? 0;
          _pendingPayments = summary['pending_payments'] ?? 0;
          _failedPayments = summary['failed_payments'] ?? 0;
        });
      }

      // Calculate today's revenue
      final today = DateTime.now();
      _payments.where((p) =>
          p.createdAt.year == today.year &&
          p.createdAt.month == today.month &&
          p.createdAt.day == today.day &&
          p.status == PaymentStatus.completed);
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _loadPayments({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    if (!mounted) return;

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

      if (mounted) {
        setState(() {
          _payments = _applyQuickFilter(payments as List<Payment>);
          _totalCount = totalCount as int;
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

  List<Payment> _applyQuickFilter(List<Payment> payments) {
    final now = DateTime.now();
    switch (_quickFilter) {
      case 'today':
        return payments
            .where((p) =>
                p.createdAt.year == now.year &&
                p.createdAt.month == now.month &&
                p.createdAt.day == now.day)
            .toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return payments.where((p) => p.createdAt.isAfter(weekAgo)).toList();
      case 'month':
        return payments
            .where((p) =>
                p.createdAt.year == now.year && p.createdAt.month == now.month)
            .toList();
      default:
        return payments;
    }
  }

  Future<void> _updatePaymentStatus(
      String paymentId, PaymentStatus status) async {
    try {
      await _paymentService.updatePaymentStatus(paymentId, status);
      _loadPayments();
      _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Payment status updated to ${status.value}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDetailsDialog(payment: payment),
    );
  }

  void _exportPayments() {
    // TODO: Implement CSV/PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: _isLoading && _payments.isEmpty
                ? _buildLoading(colors)
                : _buildContent(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalCount} ${_totalCount == 1 ? 'Payment' : 'Payments'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // View Toggle
              Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isGridView = true),
                      icon: Icon(
                        Icons.grid_view,
                        color:
                            _isGridView ? colors.primary : colors.textSecondary,
                      ),
                      tooltip: 'Grid View',
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = false),
                      icon: Icon(
                        Icons.view_list,
                        color: !_isGridView
                            ? colors.primary
                            : colors.textSecondary,
                      ),
                      tooltip: 'List View',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Export Button
              IconButton(
                onPressed: _exportPayments,
                icon: Icon(Icons.download, color: colors.textSecondary),
                tooltip: 'Export',
              ),
              IconButton(
                onPressed: () => _loadPayments(resetPage: true),
                icon: Icon(Icons.refresh, color: colors.textSecondary),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'Search by payment ID, order ID, customer ID, or transaction ID...',
              prefixIcon: Icon(Icons.search, color: colors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: colors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Quick Date Filters
                _buildFilterChip(colors, 'All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'Today', 'today', Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'This Week', 'week', Colors.purple),
                const SizedBox(width: 8),
                _buildFilterChip(colors, 'This Month', 'month', Colors.green),
                const SizedBox(width: 16),

                // Status Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<PaymentStatus?>(
                    value: _statusFilter,
                    underline: const SizedBox(),
                    hint: Text('Status', style: TextStyle(color: colors.textSecondary)),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Status')),
                      ...PaymentStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.value),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                      _loadPayments(resetPage: true);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Mode Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<PaymentMode?>(
                    value: _modeFilter,
                    underline: const SizedBox(),
                    hint: Text('Mode', style: TextStyle(color: colors.textSecondary)),
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
                      setState(() => _modeFilter = value);
                      _loadPayments(resetPage: true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AppThemeColors colors, String label, String value,
      [Color? color]) {
    final isSelected = _quickFilter == value;
    final chipColor = color ?? colors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _quickFilter = selected ? value : 'all');
        _loadPayments(resetPage: true);
      },
      backgroundColor: colors.background,
      selectedColor: chipColor.withOpacity(0.15),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? chipColor.withOpacity(0.5)
            : colors.textSecondary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildLoading(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading Payments...',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppThemeColors colors) {
    if (_error != null) {
      return _buildErrorState(colors);
    }

    if (_payments.isEmpty && !_isLoading) {
      return _buildEmptyState(colors);
    }

    return RefreshIndicator(
      onRefresh: () => _loadPayments(resetPage: true),
      color: colors.primary,
      child: Column(
        children: [
          _buildStatsBar(colors),
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
          if (_totalCount > _limit) _buildPagination(colors),
        ],
      ),
    );
  }

  Widget _buildStatsBar(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(colors, 'Total', _totalCount.toString(),
              Icons.receipt_long, colors.primary),
          _buildStatItem(colors, 'Amount', '₹${_totalAmount.toStringAsFixed(0)}',
              Icons.payments, colors.info),
          _buildStatItem(colors, 'Completed', _completedPayments.toString(),
              Icons.check_circle, colors.success),
          _buildStatItem(colors, 'Pending', _pendingPayments.toString(),
              Icons.pending, colors.warning),
          _buildStatItem(colors, 'Failed', _failedPayments.toString(),
              Icons.cancel, colors.error),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppThemeColors colors, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading payments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadPayments(resetPage: true),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment_outlined,
              size: 60,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No payments found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          if (_statusFilter != null ||
              _modeFilter != null ||
              _quickFilter != 'all') ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _modeFilter = null;
                  _quickFilter = 'all';
                  _searchController.clear();
                });
                _loadPayments(resetPage: true);
              },
              child: const Text('Clear All Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.0,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 280,
      ),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return PaymentCard(
          payment: payment,
          onViewDetails: () => _showPaymentDetails(payment),
          onUpdateStatus: (status) =>
              _updatePaymentStatus(payment.paymentId, status),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PaymentCard(
            payment: payment,
            onViewDetails: () => _showPaymentDetails(payment),
            onUpdateStatus: (status) =>
                _updatePaymentStatus(payment.paymentId, status),
          ),
        );
      },
    );
  }

  Widget _buildPagination(AppThemeColors colors) {
    final totalPages = (_totalCount / _limit).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${(_currentPage - 1) * _limit + 1}-${_currentPage * _limit > _totalCount ? _totalCount : _currentPage * _limit} of $_totalCount',
            style: TextStyle(color: colors.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadPayments();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Page $_currentPage of $totalPages',
                style: TextStyle(color: colors.textPrimary),
              ),
              IconButton(
                onPressed: _currentPage < totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _loadPayments();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailsDialog extends StatelessWidget {
  final Payment payment;

  const _PaymentDetailsDialog({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(colors, 'Payment ID', payment.paymentId),
            _buildDetailRow(colors, 'Order ID', payment.orderId),
            _buildDetailRow(colors, 'Customer', payment.customerName),
            _buildDetailRow(colors, 'Customer ID', payment.customerId),
            _buildDetailRow(colors, 'Amount', payment.formattedAmount),
            _buildDetailRow(colors, 'Payment Mode', payment.paymentMode.value),
            _buildDetailRow(colors, 'Status', payment.status.value),
            _buildDetailRow(colors, 'Transaction ID',
                payment.transactionId ?? 'N/A'),
            _buildDetailRow(colors, 'Date', payment.formattedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(AppThemeColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
  