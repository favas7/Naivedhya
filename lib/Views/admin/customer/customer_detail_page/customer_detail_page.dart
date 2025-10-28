import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/customer/widgets/customer_dialogs.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/models/customer_model.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/models/payment_model.dart';
import 'package:naivedhya/services/customer_service.dart';
import 'package:naivedhya/services/order/order_service.dart';
import 'package:naivedhya/services/payment_service.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatefulWidget {
  final UserModel customer;
  final String heroTag;

  const CustomerDetailPage({
    super.key,
    required this.customer,
    required this.heroTag,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CustomerService _customerService = CustomerService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService.instance;

  late UserModel _currentCustomer; 
  List<Order> _orders = [];
  List<Payment> _payments = [];
  bool _isLoadingOrders = false;
  bool _isLoadingPayments = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    debugPrint('🔹 initState called');
    debugPrint('➡️ Received customer from previous page: ${_currentCustomer.toJson()}');

    _tabController = TabController(length: 3, vsync: this);
    _loadCustomerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerData() async {
    debugPrint('📦 Starting _loadCustomerData...');
    await Future.wait([
      _loadCustomerDetails(),
      _loadOrders(),
      _loadPayments(),
    ]);
    debugPrint('✅ Completed _loadCustomerData');
  }

  Future<void> _loadCustomerDetails() async {
    debugPrint('📥 Fetching customer details for ID: ${_currentCustomer.id}');
    try {
      final fetchedCustomer =
          await _customerService.getCustomerById(_currentCustomer.id!);

      if (fetchedCustomer != null) {
        debugPrint('✅ Customer fetched from Supabase: ${fetchedCustomer.toJson()}');
        setState(() {
          _currentCustomer = fetchedCustomer;
        });
      } else {
        debugPrint('⚠️ No customer found with ID: ${_currentCustomer.id}');
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch customer details: $e');
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _errorMessage = null;
    });

    debugPrint('📦 Loading orders for customer ID: ${_currentCustomer.id}');
    try {
      final orders =
          await _orderService.fetchOrdersByCustomerId(_currentCustomer.id!);
      debugPrint('✅ Orders fetched: ${orders.length}');
      setState(() {
        _orders = orders;
        _isLoadingOrders = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load orders: $e');
      setState(() {
        _errorMessage = 'Failed to load orders: ${e.toString()}';
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoadingPayments = true;
    });

    debugPrint('📦 Loading payments for customer ID: ${_currentCustomer.id}');
    try {
      final payments =
          await _paymentService.getPaymentsByCustomerId(_currentCustomer.id!);
      debugPrint('✅ Payments fetched: ${payments.length}');
      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load payments: $e');
      setState(() {
        _isLoadingPayments = false;
      });
    }
  }

  Future<void> _handleEdit() async {
    debugPrint('✏️ Edit button clicked for customer: ${_currentCustomer.id}');
    final customer = Customer.fromUserModel(_currentCustomer);

    await showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(
        customer: customer,
        onCustomerUpdated: (updatedCustomer) async {
          debugPrint('🧩 Updating customer...');
          try {
            final updated = await _customerService.updateCustomer(
              updatedCustomer.id,
              {
                'name': updatedCustomer.name,
                'email': updatedCustomer.email,
                'phone': updatedCustomer.phone,
                'address': updatedCustomer.address,
              },
            );
            debugPrint('✅ Customer updated: ${updated.toJson()}');
            setState(() {
              _currentCustomer = updated;
            });
          } catch (e) {
            debugPrint('❌ Failed to update customer: $e');
            if (mounted) {
              CustomerDialogs.showErrorSnackbar(
                context: context,
                message: 'Failed to update customer: ${e.toString()}',
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _handleDelete() async {
    debugPrint('🗑️ Delete button clicked for customer: ${_currentCustomer.id}');
    final confirmed = await CustomerDialogs.showDeleteConfirmation(
      context: context,
      customer: _currentCustomer,
    );

    if (confirmed == true && mounted) {
      try {
        await _customerService.deleteCustomer(_currentCustomer.id!);
        debugPrint('✅ Customer deleted successfully');
        if (mounted) {
          Navigator.of(context).pop(true);
          CustomerDialogs.showSuccessSnackbar(
            context: context,
            message: 'Customer deleted successfully',
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to delete customer: $e');
        if (mounted) {
          CustomerDialogs.showErrorSnackbar(
            context: context,
            message: 'Failed to delete customer: ${e.toString()}',
          );
        }
      }
    }
  }

  Future<void> _handleMarkPaymentAsPaid(Payment payment) async {
    debugPrint('💰 Marking payment as paid: ${payment.paymentId}');
    try {
      await _paymentService.updatePaymentStatus(
        payment.paymentId,
        PaymentStatus.completed,
      );

      final updatedCustomer =
          await _customerService.getCustomerById(_currentCustomer.id!);
      if (updatedCustomer != null) {
        debugPrint('✅ Updated customer after payment: ${updatedCustomer.toJson()}');
        setState(() {
          _currentCustomer = updatedCustomer;
        });
      }

      await _loadPayments();

      if (mounted) {
        CustomerDialogs.showSuccessSnackbar(
          context: context,
          message: 'Payment marked as paid',
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to mark payment as paid: $e');
      if (mounted) {
        CustomerDialogs.showErrorSnackbar(
          context: context,
          message: 'Failed to update payment: ${e.toString()}',
        );
      }
    }
  }

  // --- UI below (unchanged, no need to modify print statements) ---
  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 Building CustomerDetailPage for: ${_currentCustomer.name}');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCustomerHeader(),
                _buildStatsCards(),
                _buildTabBar(),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildOrdersTab(),
                _buildPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      _currentCustomer.name.isNotEmpty
                          ? _currentCustomer.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _handleEdit,
          tooltip: 'Edit Customer',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _handleDelete,
          tooltip: 'Delete Customer',
        ),
      ],
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _currentCustomer.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _currentCustomer.email,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (_currentCustomer.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _currentCustomer.phone,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.shopping_bag,
              title: 'Total Orders',
              value: _orders.length.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.account_balance_wallet,
              title: 'Pending Payments',
              value: '₹${_currentCustomer.pendingpayments?.toStringAsFixed(2) ?? '0.00'}',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'Details', icon: Icon(Icons.person)),
          Tab(text: 'Orders', icon: Icon(Icons.shopping_bag)),
          Tab(text: 'Payments', icon: Icon(Icons.payment)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection(
            title: 'Personal Information',
            children: [
              _buildDetailRow(
                icon: Icons.person,
                label: 'Name',
                value: _currentCustomer.name,
              ),
              _buildDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: _currentCustomer.email,
              ),
              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: _currentCustomer.phone.isNotEmpty
                    ? _currentCustomer.phone 
                    : 'N/A',
              ),
              _buildDetailRow(
                icon: Icons.home,
                label: 'Address',
                value: _currentCustomer.address ?? 'N/A',)

            ],
          )
,
          const SizedBox(height: 24),
          _buildDetailSection(
            title: 'Account Information',
            children: [
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: DateFormat('MMM dd, yyyy').format(_currentCustomer.created_at),
              ),
              _buildDetailRow(
                icon: Icons.update,
                label: 'Last Updated',
                value: DateFormat('MMM dd, yyyy').format(_currentCustomer.updated_at),
              ),
              _buildDetailRow(
                icon: Icons.badge,
                label: 'Customer ID',
                value: _currentCustomer.id ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

Widget _buildDetailRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.black87),
    title: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    trailing: Text(
      value,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.black, // ensures visibility
      ),
    ),
  );
}


  Widget _buildOrdersTab() {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to order details if needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt ?? DateTime.now()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (order.deliveryStatus != null)
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          order.deliveryStatus!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No payment transactions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    Color statusColor;
    switch (payment.status) {
      case PaymentStatus.completed:
        statusColor = Colors.green;
        break;
      case PaymentStatus.failed:
        statusColor = Colors.red;
        break;
      case PaymentStatus.pending:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.formattedAmount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.paymentMode.value,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    payment.status.value.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildPaymentDetailRow(
              icon: Icons.receipt,
              label: 'Order ID',
              value: payment.orderId.substring(0, 8),
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 8),
              _buildPaymentDetailRow(
                icon: Icons.confirmation_number,
                label: 'Transaction ID',
                value: payment.transactionId!,
              ),
            ],
            const SizedBox(height: 8),
            _buildPaymentDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: payment.formattedDate,
            ),
            if (payment.status == PaymentStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkPaymentAsPaid(payment),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}