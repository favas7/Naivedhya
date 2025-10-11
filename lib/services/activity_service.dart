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
      final response = await _supabase
          .from('activities')
          .select()
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List)
          .map((json) => ActivityModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching activities: $e');
      throw Exception('Failed to load activities');
    }
  }

  // Get total count of activities
  Future<int> getActivitiesCount() async {
    try {
      final response = await _supabase
          .from('activities')
          .select()
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      print('Error getting activities count: $e');
      return 0;
    }
  }

  // Mark activity as read
  Future<void> markAsRead(String activityId) async {
    try {
      await _supabase
          .from('activities')
          .update({'is_read': true})
          .eq('id', activityId);
    } catch (e) {
      print('Error marking activity as read: $e');
    }
  }

  // Mark all activities as read
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('activities')
          .update({'is_read': true})
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all activities as read: $e');
    }
  }

  // Subscribe to real-time updates
  void subscribeToActivities(Function(List<ActivityModel>) onUpdate) {
    _activitySubscription = _supabase
        .channel('activities_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'activities',
          callback: (payload) async {
            // Fetch latest activities when change occurs
            final activities = await getActivities();
            onUpdate(activities);
          },
        )
        .subscribe();
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromActivities() {
    _activitySubscription?.unsubscribe();
    _activitySubscription = null;
  }

  // Get revenue milestones
  Future<List<RevenueMilestone>> getRevenueMilestones() async {
    try {
      final response = await _supabase
          .from('revenue_milestones')
          .select()
          .eq('is_active', true)
          .order('milestone_type');

      return (response as List)
          .map((json) => RevenueMilestone.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching revenue milestones: $e');
      throw Exception('Failed to load revenue milestones');
    }
  }

  // Update revenue milestone
  Future<void> updateRevenueMilestone(String id, double targetAmount) async {
    try {
      await _supabase
          .from('revenue_milestones')
          .update({
            'target_amount': targetAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('Error updating revenue milestone: $e');
      throw Exception('Failed to update milestone');
    }
  }

  // Manually trigger milestone check (useful for testing)
  Future<void> checkMilestones() async {
    try {
      await _supabase.rpc('check_revenue_milestones');
    } catch (e) {
      print('Error checking milestones: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('activities')
          .select()
          .eq('is_read', false)
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}