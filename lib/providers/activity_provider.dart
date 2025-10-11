import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService = ActivityService();
  
  List<ActivityModel> _activities = [];
  List<RevenueMilestone> _milestones = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalActivities = 0;
  int _unreadCount = 0;
  static const int _itemsPerPage = 20;

  List<ActivityModel> get activities => _activities;
  List<RevenueMilestone> get milestones => _milestones;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => (_totalActivities / _itemsPerPage).ceil();
  int get unreadCount => _unreadCount;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  ActivityProvider() {
    initialize();
  }

  // Initialize and subscribe to real-time updates
  Future<void> initialize() async {
    await fetchActivities();
    await fetchMilestones();
    await fetchUnreadCount();
    _subscribeToUpdates();
  }

  // Subscribe to real-time updates
  void _subscribeToUpdates() {
    _activityService.subscribeToActivities((newActivities) {
      _activities = newActivities;
      fetchUnreadCount();
      notifyListeners();
    });
  }

  // Fetch activities
  Future<void> fetchActivities({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      _activities = await _activityService.getActivities(
        page: page,
        limit: _itemsPerPage,
      );
      _totalActivities = await _activityService.getActivitiesCount();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch milestones
  Future<void> fetchMilestones() async {
    try {
      _milestones = await _activityService.getRevenueMilestones();
      notifyListeners();
    } catch (e) {
      print('Error fetching milestones: $e');
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _activityService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  // Mark activity as read
  Future<void> markAsRead(String activityId) async {
    try {
      await _activityService.markAsRead(activityId);
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        _activities[index] = ActivityModel(
          id: _activities[index].id,
          activityType: _activities[index].activityType,
          title: _activities[index].title,
          description: _activities[index].description,
          orderId: _activities[index].orderId,
          customerId: _activities[index].customerId,
          deliveryPartnerName: _activities[index].deliveryPartnerName,
          oldStatus: _activities[index].oldStatus,
          newStatus: _activities[index].newStatus,
          amount: _activities[index].amount,
          metadata: _activities[index].metadata,
          createdAt: _activities[index].createdAt,
          isRead: true,
        );
        await fetchUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _activityService.markAllAsRead();
      await fetchActivities(page: _currentPage);
      await fetchUnreadCount();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // Update milestone
  Future<void> updateMilestone(String id, double targetAmount) async {
    try {
      await _activityService.updateRevenueMilestone(id, targetAmount);
      await fetchMilestones();
    } catch (e) {
      throw Exception('Failed to update milestone');
    }
  }

  // Refresh activities
  Future<void> refresh() async {
    await fetchActivities(page: 1);
    await fetchMilestones();
    await fetchUnreadCount();
  }

  // Next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await fetchActivities(page: _currentPage + 1);
    }
  }

  // Previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      await fetchActivities(page: _currentPage - 1);
    }
  }

  @override
  void dispose() {
    _activityService.unsubscribeFromActivities();
    super.dispose();
  }
}