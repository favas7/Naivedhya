import 'dart:async';
import 'package:naivedhya/models/payment_model.dart';
import 'package:naivedhya/services/restaurant_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();

  PaymentService._();

  final SupabaseClient _client =  RestaurantService().client;

  /// Fetch payments with pagination and search
  Future<List<Payment>> getPayments({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    PaymentStatus? statusFilter,
    PaymentMode? modeFilter,
  }) async {
    try {
      var query = _client.from('payments').select('''
        paymentid,
        orderid,
        customerid,
        amount,
        paymentmode,
        status,
        transactionid,
        created_at,
        updated_at,
        profiles!payments_customerid_fkey (
          name
        )
      ''');

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'paymentid.ilike.%$searchQuery%,'
          'orderid.ilike.%$searchQuery%,'
          'customerid.ilike.%$searchQuery%,'
          'transactionid.ilike.%$searchQuery%',
        );
      }

      // Apply status filter
      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }

      // Apply payment mode filter
      if (modeFilter != null) {
        query = query.eq('paymentmode', modeFilter.value);
      }

      // Apply order and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List).map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Get total count of payments for pagination
  Future<int> getPaymentsCount({
    String? searchQuery,
    PaymentStatus? statusFilter,
    PaymentMode? modeFilter,
  }) async {
    try {
      var query = _client.from('payments').select('paymentid');

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'paymentid.ilike.%$searchQuery%,'
          'orderid.ilike.%$searchQuery%,'
          'customerid.ilike.%$searchQuery%,'
          'transactionid.ilike.%$searchQuery%',
        );
      }

      // Apply status filter
      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }

      // Apply payment mode filter
      if (modeFilter != null) {
        query = query.eq('paymentmode', modeFilter.value);
      }

      final response = await query.count(CountOption.exact);
      return response.count;
    } catch (e) {
      throw Exception('Failed to get payments count: $e');
    }
  }

  /// Subscribe to payment changes for real-time updates
  RealtimeChannel subscribeToPayments(Function(List<Payment>) onPaymentsChanged) {
    return _client
        .channel('payments-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'payments',
          callback: (payload) async {
            // When a change occurs, fetch updated data
            try {
              final updatedPayments = await getPayments();
              onPaymentsChanged(updatedPayments);
            } catch (e) {
              print('Error updating payments: $e');
            }
          },
        )
        .subscribe();
  }

  /// Update payment status
  Future<Payment?> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      final response = await _client
          .from('payments')
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('paymentid', paymentId)
          .select('''
            paymentid,
            orderid,
            customerid,
            amount,
            paymentmode,
            status,
            transactionid,
            created_at,
            updated_at,
            profiles!payments_customerid_fkey (
              name
            )
          ''')
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get payment by ID
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final response = await _client
          .from('payments')
          .select('''
            paymentid,
            orderid,
            customerid,
            amount,
            paymentmode,
            status,
            transactionid,
            created_at,
            updated_at,
            profiles!payments_customerid_fkey (
              name
            )
          ''')
          .eq('paymentid', paymentId)
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch payment: $e');
    }
  }

  /// Get payments summary/statistics
  Future<Map<String, dynamic>> getPaymentsSummary() async {
    try {
      final response = await _client.rpc('get_payments_summary');
      return response as Map<String, dynamic>;
    } catch (e) {
      // If RPC function doesn't exist, calculate manually
      try {
        final allPayments = await _client.from('payments').select('amount, status');

        double totalAmount = 0;
        int completedCount = 0;
        int pendingCount = 0;
        int failedCount = 0;

        for (final payment in allPayments) {
          final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;
          totalAmount += amount;

          switch (payment['status']) {
            case 'Completed':
              completedCount++;
              break;
            case 'Pending':
              pendingCount++;
              break;
            case 'Failed':
              failedCount++;
              break;
          }
        }

        return {
          'total_amount': totalAmount,
          'total_payments': allPayments.length,
          'completed_payments': completedCount,
          'pending_payments': pendingCount,
          'failed_payments': failedCount,
        };
      } catch (e) {
        throw Exception('Failed to get payments summary: $e');
      }
    }
  }
}