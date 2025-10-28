import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_model.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _activitySubscription;

  // Fetch activities with pagination
  Future<List<ActivityModel>> getActivities({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 [ActivityService] Fetching activities - Page: $page, Limit: $limit');
      
      final startRange = (page - 1) * limit;
      final endRange = page * limit - 1;
      
      print('🔍 [ActivityService] Range: $startRange to $endRange');
      
      final response = await _supabase
          .from('activities')
          .select()
          .order('created_at', ascending: false)
          .range(startRange, endRange);

      print('✅ [ActivityService] Response received: ${response.length} activities');
      print('📊 [ActivityService] First activity (if any): ${response.isNotEmpty ? response.first : "No activities"}');

      final activities = (response as List)
          .map((json) => ActivityModel.fromJson(json))
          .toList();
      
      print('✅ [ActivityService] Parsed ${activities.length} activities successfully');
      
      return activities;
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error fetching activities: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      throw Exception('Failed to load activities: $e');
    }
  }

  // Get total count of activities
  Future<int> getActivitiesCount() async {
    try {
      print('🔍 [ActivityService] Fetching activities count...');
      
      final response = await _supabase
          .from('activities')
          .select()
          .count(CountOption.exact);
      
      final count = response.count;
      print('✅ [ActivityService] Total activities count: $count');
      
      return count;
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error getting activities count: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      return 0;
    }
  }

  // Mark activity as read
  Future<void> markAsRead(String activityId) async {
    try {
      print('🔍 [ActivityService] Marking activity as read: $activityId');
      
      await _supabase
          .from('activities')
          .update({'is_read': true})
          .eq('id', activityId);
      
      print('✅ [ActivityService] Activity marked as read: $activityId');
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error marking activity as read: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
    }
  }

  // Mark all activities as read
  Future<void> markAllAsRead() async {
    try {
      print('🔍 [ActivityService] Marking all activities as read...');
      
      final _ = await _supabase
          .from('activities')
          .update({'is_read': true})
          .eq('is_read', false);
      
      print('✅ [ActivityService] All activities marked as read');
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error marking all activities as read: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
    }
  }

  // Subscribe to real-time updates
  void subscribeToActivities(Function(List<ActivityModel>) onUpdate) {
    print('🔍 [ActivityService] Subscribing to real-time activity updates...');
    
    try {
      _activitySubscription = _supabase
          .channel('activities_channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'activities',
            callback: (payload) async {
              print('🔔 [ActivityService] Real-time update received!');
              print('📊 [ActivityService] Payload: ${payload.eventType}');
              print('📊 [ActivityService] New data: ${payload.newRecord}');
              
              // Fetch latest activities when change occurs
              try {
                final activities = await getActivities();
                print('✅ [ActivityService] Fetched ${activities.length} activities after real-time update');
                onUpdate(activities);
              } catch (e) {
                print('❌ [ActivityService] Error fetching activities after real-time update: $e');
              }
            },
          )
          .subscribe((status, error) {
            print('📡 [ActivityService] Subscription status: $status');
            if (error != null) {
              print('❌ [ActivityService] Subscription error: $error');
            }
          });
      
      print('✅ [ActivityService] Successfully subscribed to activities channel');
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error subscribing to activities: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
    }
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromActivities() {
    print('🔍 [ActivityService] Unsubscribing from activities...');
    
    _activitySubscription?.unsubscribe();
    _activitySubscription = null;
    
    print('✅ [ActivityService] Unsubscribed from activities');
  }

  // Get revenue milestones
  Future<List<RevenueMilestone>> getRevenueMilestones() async {
    try {
      print('🔍 [ActivityService] Fetching revenue milestones...');
      
      final response = await _supabase
          .from('revenue_milestones')
          .select()
          .eq('is_active', true)
          .order('milestone_type');

      print('✅ [ActivityService] Fetched ${response.length} revenue milestones');
      print('📊 [ActivityService] Milestones: $response');

      return (response as List)
          .map((json) => RevenueMilestone.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error fetching revenue milestones: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      throw Exception('Failed to load revenue milestones: $e');
    }
  }

  // Update revenue milestone
  Future<void> updateRevenueMilestone(String id, double targetAmount) async {
    try {
      print('🔍 [ActivityService] Updating milestone: $id to amount: $targetAmount');
      
      await _supabase
          .from('revenue_milestones')
          .update({
            'target_amount': targetAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      print('✅ [ActivityService] Milestone updated successfully');
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error updating revenue milestone: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      throw Exception('Failed to update milestone: $e');
    }
  }

  // Manually trigger milestone check (useful for testing)
  Future<void> checkMilestones() async {
    try {
      print('🔍 [ActivityService] Manually checking milestones...');
      
      await _supabase.rpc('check_revenue_milestones');
      
      print('✅ [ActivityService] Milestone check completed');
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error checking milestones: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      print('🔍 [ActivityService] Fetching unread count...');
      
      final response = await _supabase
          .from('activities')
          .select()
          .eq('is_read', false)
          .count(CountOption.exact);
      
      final count = response.count;
      print('✅ [ActivityService] Unread count: $count');
      
      return count;
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Error getting unread count: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      return 0;
    }
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      print('🔍 [ActivityService] Testing database connection...');
      
      final _ = await _supabase
          .from('activities')
          .select()
          .limit(1);
      
      print('✅ [ActivityService] Database connection successful');
      return true;
    } catch (e, stackTrace) {
      print('❌ [ActivityService] Database connection failed: $e');
      print('📍 [ActivityService] Stack trace: $stackTrace');
      return false;
    }
  }
}