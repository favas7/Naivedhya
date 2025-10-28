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
    print('🚀 [ActivityProvider] Initializing...');
    initialize();
  }

  // Initialize and subscribe to real-time updates
  Future<void> initialize() async {
    print('🔍 [ActivityProvider] Starting initialization...');
    
    try {
      // Test connection first
      final isConnected = await _activityService.testConnection();
      print('📡 [ActivityProvider] Connection status: ${isConnected ? "Connected ✅" : "Failed ❌"}');
      
      if (!isConnected) {
        _error = 'Database connection failed';
        notifyListeners();
        return;
      }

      await fetchActivities();
      await fetchMilestones();
      await fetchUnreadCount();
      _subscribeToUpdates();
      
      print('✅ [ActivityProvider] Initialization complete!');
      print('📊 [ActivityProvider] Activities: ${_activities.length}');
      print('📊 [ActivityProvider] Milestones: ${_milestones.length}');
      print('📊 [ActivityProvider] Unread: $_unreadCount');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Initialization failed: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
      _error = 'Initialization failed: $e';
      notifyListeners();
    }
  }

  // Subscribe to real-time updates
  void _subscribeToUpdates() {
    print('🔍 [ActivityProvider] Setting up real-time subscriptions...');
    
    try {
      _activityService.subscribeToActivities((newActivities) {
        print('🔔 [ActivityProvider] Real-time update received!');
        print('📊 [ActivityProvider] New activities count: ${newActivities.length}');
        
        _activities = newActivities;
        fetchUnreadCount();
        notifyListeners();
        
        print('✅ [ActivityProvider] UI updated with new activities');
      });
      
      print('✅ [ActivityProvider] Real-time subscriptions active');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Failed to subscribe to updates: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Fetch activities
  Future<void> fetchActivities({int page = 1}) async {
    print('🔍 [ActivityProvider] Fetching activities - Page: $page');
    
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      print('⏳ [ActivityProvider] Loading activities...');
      
      _activities = await _activityService.getActivities(
        page: page,
        limit: _itemsPerPage,
      );
      
      print('✅ [ActivityProvider] Fetched ${_activities.length} activities');
      
      _totalActivities = await _activityService.getActivitiesCount();
      
      print('📊 [ActivityProvider] Total activities in DB: $_totalActivities');
      print('📊 [ActivityProvider] Total pages: $totalPages');
      
      _isLoading = false;
      notifyListeners();
      
      print('✅ [ActivityProvider] Activities loaded successfully');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error fetching activities: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
      
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch milestones
  Future<void> fetchMilestones() async {
    print('🔍 [ActivityProvider] Fetching milestones...');
    
    try {
      _milestones = await _activityService.getRevenueMilestones();
      
      print('✅ [ActivityProvider] Fetched ${_milestones.length} milestones');
      
      if (_milestones.isNotEmpty) {
        print('📊 [ActivityProvider] Milestone types: ${_milestones.map((m) => m.milestoneType).join(", ")}');
      }
      
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error fetching milestones: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    print('🔍 [ActivityProvider] Fetching unread count...');
    
    try {
      _unreadCount = await _activityService.getUnreadCount();
      
      print('✅ [ActivityProvider] Unread count: $_unreadCount');
      
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error fetching unread count: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Mark activity as read
  Future<void> markAsRead(String activityId) async {
    print('🔍 [ActivityProvider] Marking activity as read: $activityId');
    
    try {
      await _activityService.markAsRead(activityId);
      
      final index = _activities.indexWhere((a) => a.id == activityId);
      
      if (index != -1) {
        print('✅ [ActivityProvider] Found activity at index: $index');
        
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
        
        print('✅ [ActivityProvider] Activity marked as read');
      } else {
        print('⚠️ [ActivityProvider] Activity not found in list');
      }
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error marking as read: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    print('🔍 [ActivityProvider] Marking all activities as read...');
    
    try {
      await _activityService.markAllAsRead();
      await fetchActivities(page: _currentPage);
      await fetchUnreadCount();
      
      print('✅ [ActivityProvider] All activities marked as read');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error marking all as read: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Update milestone
  Future<void> updateMilestone(String id, double targetAmount) async {
    print('🔍 [ActivityProvider] Updating milestone: $id to $targetAmount');
    
    try {
      await _activityService.updateRevenueMilestone(id, targetAmount);
      await fetchMilestones();
      
      print('✅ [ActivityProvider] Milestone updated successfully');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error updating milestone: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
      throw Exception('Failed to update milestone');
    }
  }

  // Refresh activities
  Future<void> refresh() async {
    print('🔄 [ActivityProvider] Refreshing all data...');
    
    try {
      await fetchActivities(page: 1);
      await fetchMilestones();
      await fetchUnreadCount();
      
      print('✅ [ActivityProvider] Refresh complete');
    } catch (e, stackTrace) {
      print('❌ [ActivityProvider] Error during refresh: $e');
      print('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Next page
  Future<void> nextPage() async {
    print('🔍 [ActivityProvider] Navigating to next page...');
    
    if (hasNextPage) {
      await fetchActivities(page: _currentPage + 1);
    } else {
      print('⚠️ [ActivityProvider] Already on last page');
    }
  }

  // Previous page
  Future<void> previousPage() async {
    print('🔍 [ActivityProvider] Navigating to previous page...');
    
    if (hasPreviousPage) {
      await fetchActivities(page: _currentPage - 1);
    } else {
      print('⚠️ [ActivityProvider] Already on first page');
    }
  }

  @override
  void dispose() {
    print('🔍 [ActivityProvider] Disposing...');
    
    _activityService.unsubscribeFromActivities();
    
    print('✅ [ActivityProvider] Disposed');
    
    super.dispose();
  }
}