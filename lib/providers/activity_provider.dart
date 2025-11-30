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
    ///('🚀 [ActivityProvider] Initializing...');
    initialize();
  }

  // Initialize and subscribe to real-time updates
  Future<void> initialize() async {
    ///('🔍 [ActivityProvider] Starting initialization...');
    
    try {
      // Test connection first
      final isConnected = await _activityService.testConnection();
      ///('📡 [ActivityProvider] Connection status: ${isConnected ? "Connected ✅" : "Failed ❌"}');
      
      if (!isConnected) {
        _error = 'Database connection failed';
        notifyListeners();
        return;
      }

      await fetchActivities();
      await fetchMilestones();
      await fetchUnreadCount();
      _subscribeToUpdates();
      
      ///('✅ [ActivityProvider] Initialization complete!');
      ///('📊 [ActivityProvider] Activities: ${_activities.length}');
      ///('📊 [ActivityProvider] Milestones: ${_milestones.length}');
      ///('📊 [ActivityProvider] Unread: $_unreadCount');
    } catch (e) {
      ///('❌ [ActivityProvider] Initialization failed: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
      _error = 'Initialization failed: $e';
      notifyListeners();
    }
  }

  // Subscribe to real-time updates
  void _subscribeToUpdates() {
    ///('🔍 [ActivityProvider] Setting up real-time subscriptions...');
    
    try {
      _activityService.subscribeToActivities((newActivities) {
        ///('🔔 [ActivityProvider] Real-time update received!');
        ///('📊 [ActivityProvider] New activities count: ${newActivities.length}');
        
        _activities = newActivities;
        fetchUnreadCount();
        notifyListeners();
        
        ///('✅ [ActivityProvider] UI updated with new activities');
      });
      
      ///('✅ [ActivityProvider] Real-time subscriptions active');
    } catch (e) {
      ///('❌ [ActivityProvider] Failed to subscribe to updates: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Fetch activities
  Future<void> fetchActivities({int page = 1}) async {
    ///('🔍 [ActivityProvider] Fetching activities - Page: $page');
    
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      ///('⏳ [ActivityProvider] Loading activities...');
      
      _activities = await _activityService.getActivities(
        page: page,
        limit: _itemsPerPage,
      );
      
      ///('✅ [ActivityProvider] Fetched ${_activities.length} activities');
      
      _totalActivities = await _activityService.getActivitiesCount();
      
      ///('📊 [ActivityProvider] Total activities in DB: $_totalActivities');
      ///('📊 [ActivityProvider] Total pages: $totalPages');
      
      _isLoading = false;
      notifyListeners();
      
      ///('✅ [ActivityProvider] Activities loaded successfully');
    } catch (e) {
      ///('❌ [ActivityProvider] Error fetching activities: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
      
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch milestones
  Future<void> fetchMilestones() async {
    ///('🔍 [ActivityProvider] Fetching milestones...');
    
    try {
      _milestones = await _activityService.getRevenueMilestones();
      
      ///('✅ [ActivityProvider] Fetched ${_milestones.length} milestones');
      
      if (_milestones.isNotEmpty) {
        ///('📊 [ActivityProvider] Milestone types: ${_milestones.map((m) => m.milestoneType).join(", ")}');
      }
      
      notifyListeners();
    } catch (e) {
      ///('❌ [ActivityProvider] Error fetching milestones: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    ///('🔍 [ActivityProvider] Fetching unread count...');
    
    try {
      _unreadCount = await _activityService.getUnreadCount();
      
      ///('✅ [ActivityProvider] Unread count: $_unreadCount');
      
      notifyListeners();
    } catch (e) {
      ///('❌ [ActivityProvider] Error fetching unread count: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Mark activity as read
  Future<void> markAsRead(String activityId) async {
    ///('🔍 [ActivityProvider] Marking activity as read: $activityId');
    
    try {
      await _activityService.markAsRead(activityId);
      
      final index = _activities.indexWhere((a) => a.id == activityId);
      
      if (index != -1) {
        ///('✅ [ActivityProvider] Found activity at index: $index');
        
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
        
        ///('✅ [ActivityProvider] Activity marked as read');
      } else {
        ///('⚠️ [ActivityProvider] Activity not found in list');
      }
    } catch (e) {
      ///('❌ [ActivityProvider] Error marking as read: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    ///('🔍 [ActivityProvider] Marking all activities as read...');
    
    try {
      await _activityService.markAllAsRead();
      await fetchActivities(page: _currentPage);
      await fetchUnreadCount();
      
      ///('✅ [ActivityProvider] All activities marked as read');
    } catch (e) {
      ///('❌ [ActivityProvider] Error marking all as read: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Update milestone
  Future<void> updateMilestone(String id, double targetAmount) async {
    ///('🔍 [ActivityProvider] Updating milestone: $id to $targetAmount');
    
    try {
      await _activityService.updateRevenueMilestone(id, targetAmount);
      await fetchMilestones();
      
      ///('✅ [ActivityProvider] Milestone updated successfully');
    } catch (e) {
      ///('❌ [ActivityProvider] Error updating milestone: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
      throw Exception('Failed to update milestone');
    }
  }

  // Refresh activities
  Future<void> refresh() async {
    ///('🔄 [ActivityProvider] Refreshing all data...');
    
    try {
      await fetchActivities(page: 1);
      await fetchMilestones();
      await fetchUnreadCount();
      
      ///('✅ [ActivityProvider] Refresh complete');
    } catch (e) {
      ///('❌ [ActivityProvider] Error during refresh: $e');
      ///('📍 [ActivityProvider] Stack trace: $stackTrace');
    }
  }

  // Next page
  Future<void> nextPage() async {
    ///('🔍 [ActivityProvider] Navigating to next page...');
    
    if (hasNextPage) {
      await fetchActivities(page: _currentPage + 1);
    } else {
      ///('⚠️ [ActivityProvider] Already on last page');
    }
  }

  // Previous page
  Future<void> previousPage() async {
    ///('🔍 [ActivityProvider] Navigating to previous page...');
    
    if (hasPreviousPage) {
      await fetchActivities(page: _currentPage - 1);
    } else {
      ///('⚠️ [ActivityProvider] Already on first page');
    }
  }

  @override
  void dispose() {
    ///('🔍 [ActivityProvider] Disposing...');
    
    _activityService.unsubscribeFromActivities();
    
    ///('✅ [ActivityProvider] Disposed');
    
    super.dispose();
  }
}