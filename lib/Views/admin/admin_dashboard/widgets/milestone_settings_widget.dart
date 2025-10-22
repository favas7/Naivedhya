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
    final colors = AppTheme.of(context);

    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.milestones.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.08),
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
                    color: colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Revenue Milestones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Set target revenue goals',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colors.textSecondary,
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
    final colors = AppTheme.of(context);
    try {
      await provider.updateMilestone(milestone.id, newAmount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getMilestoneLabel(milestone.milestoneType)} milestone updated to ₹${newAmount.toStringAsFixed(2)}!',
            ),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update milestone: $e'),
            backgroundColor: colors.error,
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
    final colors = AppTheme.of(context);
    final backgroundColor = colors.primary.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
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
                  color: colors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMilestoneIcon(milestone.milestoneType),
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getMilestoneLabel(milestone.milestoneType),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18,
                  color: colors.primary,
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
                color: colors.success,
              ),
              const SizedBox(width: 4),
              Text(
                milestone.targetAmount.toStringAsFixed(2),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target goal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
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
    final colors = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit ${_getMilestoneLabel(milestone.milestoneType)} Target',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your ${_getMilestoneLabel(milestone.milestoneType).toLowerCase()} revenue target:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
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
                labelStyle: TextStyle(color: colors.textSecondary),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colors.primary,
                    width: 2,
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
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
                color: colors.textSecondary,
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
                    backgroundColor: colors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
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
}