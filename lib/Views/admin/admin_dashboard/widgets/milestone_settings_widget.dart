import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/models/activity_model.dart';
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class MilestoneSettingsWidget extends StatelessWidget {
  const MilestoneSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.milestones.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.darkShadow
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Revenue Milestones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Set target revenue goals',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Milestones Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  
                  if (isWide) {
                    // Horizontal layout for desktop
                    return Row(
                      children: provider.milestones.map((milestone) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: MilestoneTile(
                              milestone: milestone,
                              onUpdate: (newAmount) => _handleUpdate(
                                context,
                                provider,
                                milestone,
                                newAmount,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    // Vertical layout for mobile
                    return Column(
                      children: provider.milestones.map((milestone) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MilestoneTile(
                            milestone: milestone,
                            onUpdate: (newAmount) => _handleUpdate(
                              context,
                              provider,
                              milestone,
                              newAmount,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleUpdate(
    BuildContext context,
    ActivityProvider provider,
    RevenueMilestone milestone,
    double newAmount,
  ) async {
    try {
      await provider.updateMilestone(milestone.id, newAmount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getMilestoneLabel(milestone.milestoneType)} milestone updated to ₹${newAmount.toStringAsFixed(2)}!',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update milestone: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getMilestoneLabel(MilestoneType type) {
    switch (type) {
      case MilestoneType.daily:
        return 'Daily';
      case MilestoneType.weekly:
        return 'Weekly';
      case MilestoneType.monthly:
        return 'Monthly';
    }
  }
}

class MilestoneTile extends StatelessWidget {
  final RevenueMilestone milestone;
  final Function(double) onUpdate;

  const MilestoneTile({
    Key? key,
    required this.milestone,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.darkBackground.withOpacity(0.5)
        : AppTheme.background.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMilestoneColor(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMilestoneIcon(milestone.milestoneType),
                  color: _getMilestoneColor(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getMilestoneLabel(milestone.milestoneType),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18,
                  color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                ),
                onPressed: () => _showEditDialog(context),
                tooltip: 'Edit target',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 20,
                color: isDark ? AppTheme.darkSuccess : AppTheme.success,
              ),
              const SizedBox(width: 4),
              Text(
                milestone.targetAmount.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 20,
                  color: isDark ? AppTheme.darkSuccess : AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target goal',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: milestone.targetAmount.toStringAsFixed(2),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.darkCardBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit ${_getMilestoneLabel(milestone.milestoneType)} Target',
          style: TextStyle(
            color: isDark
                ? AppTheme.darkTextPrimary
                : AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your ${_getMilestoneLabel(milestone.milestoneType).toLowerCase()} revenue target:',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppTheme.darkPrimary
                        : AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(controller.text);
              if (newAmount != null && newAmount > 0) {
                onUpdate(newAmount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid amount'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? AppTheme.darkPrimary : AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _getMilestoneLabel(MilestoneType type) {
    switch (type) {
      case MilestoneType.daily:
        return 'Daily';
      case MilestoneType.weekly:
        return 'Weekly';
      case MilestoneType.monthly:
        return 'Monthly';
    }
  }

  IconData _getMilestoneIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.daily:
        return Icons.today;
      case MilestoneType.weekly:
        return Icons.calendar_view_week;
      case MilestoneType.monthly:
        return Icons.calendar_month;
    }
  }

  Color _getMilestoneColor(bool isDark) {
    return isDark ? AppTheme.darkPrimary : AppTheme.primary;
  }
}