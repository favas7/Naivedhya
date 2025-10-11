class ActivityModel {
  final String id;
  final ActivityType activityType;
  final String title;
  final String? description;
  final String? orderId;
  final String? customerId;
  final String? deliveryPartnerName;
  final String? oldStatus;
  final String? newStatus;
  final double? amount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.activityType,
    required this.title,
    this.description,
    this.orderId,
    this.customerId,
    this.deliveryPartnerName,
    this.oldStatus,
    this.newStatus,
    this.amount,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      activityType: ActivityType.fromString(json['activity_type'] ?? ''),
      title: json['title'] ?? '',
      description: json['description'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      deliveryPartnerName: json['delivery_partner_name'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType.value,
      'title': title,
      'description': description,
      'order_id': orderId,
      'customer_id': customerId,
      'delivery_partner_name': deliveryPartnerName,
      'old_status': oldStatus,
      'new_status': newStatus,
      'amount': amount,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  String getTimeAgo() {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum ActivityType {
  newOrder('new_order'),
  deliveryStatus('delivery_status'),
  newCustomer('new_customer'),
  revenueMilestone('revenue_milestone');

  final String value;
  const ActivityType(this.value);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.newOrder,
    );
  }
}

class RevenueMilestone {
  final String id;
  final MilestoneType milestoneType;
  final double targetAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RevenueMilestone({
    required this.id,
    required this.milestoneType,
    required this.targetAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RevenueMilestone.fromJson(Map<String, dynamic> json) {
    return RevenueMilestone(
      id: json['id'] ?? '',
      milestoneType: MilestoneType.fromString(json['milestone_type'] ?? 'daily'),
      targetAmount: double.parse(json['target_amount'].toString()),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestone_type': milestoneType.value,
      'target_amount': targetAmount,
      'is_active': isActive,
    };
  }
}

enum MilestoneType {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  final String value;
  const MilestoneType(this.value);

  static MilestoneType fromString(String value) {
    return MilestoneType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MilestoneType.daily,
    );
  }
}