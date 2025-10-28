// views/admin/delivery_staff/widgets/delivery_analytics_widget.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/delivery_history_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DeliveryAnalyticsWidget extends StatefulWidget {
  final Map<String, dynamic> statistics;
  final List<DeliveryHistory> deliveryHistory;

  const DeliveryAnalyticsWidget({
    super.key,
    required this.statistics,
    required this.deliveryHistory,
  });

  @override
  State<DeliveryAnalyticsWidget> createState() => _DeliveryAnalyticsWidgetState();
}

class _DeliveryAnalyticsWidgetState extends State<DeliveryAnalyticsWidget> {
  String _selectedPeriod = 'week'; // day, week, month

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(colors),
          const SizedBox(height: 24),
          _buildStatsSummary(colors),
          const SizedBox(height: 24),
          _buildDeliveryChart(colors),
          const SizedBox(height: 24),
          _buildEarningsBreakdown(colors),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(colors, 'Day', 'day'),
          ),
          Expanded(
            child: _buildPeriodButton(colors, 'Week', 'week'),
          ),
          Expanded(
            child: _buildPeriodButton(colors, 'Month', 'month'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(AppThemeColors colors, String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(AppThemeColors colors) {
    final totalDeliveries = widget.statistics['total_deliveries'] ?? 0;
    final completedDeliveries = widget.statistics['completed_deliveries'] ?? 0;
    final totalEarnings = widget.statistics['total_earnings'] ?? 0.0;
    final totalDistance = widget.statistics['total_distance'] ?? 0.0;
    final avgDeliveries = widget.statistics['average_deliveries_per_day'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics Summary (Last 30 Days)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Total Deliveries',
                  totalDeliveries.toString(),
                  Icons.local_shipping,
                  colors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Completed',
                  completedDeliveries.toString(),
                  Icons.check_circle,
                  colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Total Earnings',
                  '₹${totalEarnings.toStringAsFixed(0)}',
                  Icons.payments,
                  colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Total Distance',
                  '${totalDistance.toStringAsFixed(1)} km',
                  Icons.route,
                  colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            colors,
            'Avg Deliveries/Day',
            avgDeliveries.toStringAsFixed(1),
            Icons.trending_up,
            colors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    AppThemeColors colors,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryChart(AppThemeColors colors) {
    final chartData = _getChartData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deliveries Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: chartData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: chartData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b).toDouble() + 2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${chartData[group.x.toInt()]['label']}\n${rod.toY.toInt()} deliveries',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < chartData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    chartData[value.toInt()]['label'] as String,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colors.textSecondary.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: chartData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: (entry.value['count'] as int).toDouble(),
                              color: colors.primary,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(AppThemeColors colors) {
    final completedDeliveries = widget.deliveryHistory
        .where((d) => d.isCompleted)
        .toList();

    if (completedDeliveries.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalFees = completedDeliveries
        .fold<double>(0.0, (sum, d) => sum + d.deliveryFee);
    final totalTips = completedDeliveries
        .fold<double>(0.0, (sum, d) => sum + d.tipAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildEarningRow(
            colors,
            'Delivery Fees',
            totalFees,
            colors.info,
          ),
          const SizedBox(height: 12),
          _buildEarningRow(
            colors,
            'Tips',
            totalTips,
            colors.success,
          ),
          const Divider(height: 32),
          _buildEarningRow(
            colors,
            'Total Earnings',
            totalFees + totalTips,
            colors.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningRow(
    AppThemeColors colors,
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: colors.textPrimary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getChartData() {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];

    switch (_selectedPeriod) {
      case 'day':
        // Last 7 days
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateStr = date.toIso8601String().split('T')[0];
          final count = widget.deliveryHistory
              .where((d) => d.createdAt.toIso8601String().split('T')[0] == dateStr)
              .length;
          data.add({
            'label': DateFormat('EEE').format(date),
            'count': count,
          });
        }
        break;

      case 'week':
        // Last 4 weeks
        for (int i = 3; i >= 0; i--) {
          final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
          final weekEnd = weekStart.add(const Duration(days: 6));
          final count = widget.deliveryHistory
              .where((d) =>
                  d.createdAt.isAfter(weekStart) &&
                  d.createdAt.isBefore(weekEnd.add(const Duration(days: 1))))
              .length;
          data.add({
            'label': 'W${4 - i}',
            'count': count,
          });
        }
        break;

      case 'month':
        // Last 6 months
        for (int i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final monthEnd = DateTime(now.year, now.month - i + 1, 0);
          final count = widget.deliveryHistory
              .where((d) =>
                  d.createdAt.isAfter(month.subtract(const Duration(days: 1))) &&
                  d.createdAt.isBefore(monthEnd.add(const Duration(days: 1))))
              .length;
          data.add({
            'label': DateFormat('MMM').format(month),
            'count': count,
          });
        }
        break;
    }

    return data;
  }
}