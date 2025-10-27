// // lib/services/add_order_service.dart
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:naivedhya/models/menu_model.dart';
// import 'package:naivedhya/models/simple_delivery_person_model.dart';
// import 'package:naivedhya/models/user_model.dart';

// class AddOrderException implements Exception {
//   final String message;
//   final String? code;

//   AddOrderException({required this.message, this.code});

//   @override
//   String toString() => 'AddOrderException: $message';
// }

// class AddOrderService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // ============================================================================
//   // RESTAURANT METHODS
//   // ============================================================================

//   /// Fetch all active restaurants
//   Future<List<Map<String, dynamic>>> fetchAllRestaurants() async {
//     try {
//       final response = await _supabase
//           .from('hotels') // hotels table = restaurants
//           .select('hotel_id, name, address, enterprise_id, location_id, manager_id, adminemail')
//           .order('name', ascending: true);

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch restaurants: ${e.toString()}',
//         code: 'RESTAURANT_FETCH_ERROR',
//       );
//     }
//   }

//   /// Search restaurants by name or address
//   Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
//     if (query.isEmpty) return fetchAllRestaurants();

//     try {
//       final response = await _supabase
//           .from('hotels')
//           .select('hotel_id, name, address, enterprise_id, location_id')
//           .or('name.ilike.%$query%,address.ilike.%$query%')
//           .limit(20)
//           .order('name', ascending: true);

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to search restaurants: ${e.toString()}',
//         code: 'RESTAURANT_SEARCH_ERROR',
//       );
//     }
//   }

//   /// Get restaurant details by ID
//   Future<Map<String, dynamic>?> getRestaurantById(String restaurantId) async {
//     try {
//       final response = await _supabase
//           .from('hotels')
//           .select('hotel_id, name, address, enterprise_id, location_id, manager_id, adminemail')
//           .eq('hotel_id', restaurantId)
//           .maybeSingle();

//       return response;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch restaurant details: ${e.toString()}',
//         code: 'RESTAURANT_DETAIL_ERROR',
//       );
//     }
//   }

//   /// Fetch restaurants by location
//   Future<List<Map<String, dynamic>>> getRestaurantsByLocation(String locationId) async {
//     try {
//       final response = await _supabase
//           .from('hotels')
//           .select('hotel_id, name, address, location_id')
//           .eq('location_id', locationId)
//           .order('name', ascending: true);

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch restaurants by location: ${e.toString()}',
//         code: 'RESTAURANT_LOCATION_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // MENU ITEM METHODS
//   // ============================================================================

//   /// Fetch all menu items for a restaurant
//   Future<List<MenuItem>> fetchMenuItemsByRestaurant(String restaurantId) async {
//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('''
//             item_id,
//             hotel_id,
//             name,
//             description,
//             price,
//             is_available,
//             category,
//             stock_quantity,
//             low_stock_threshold,
//             created_at,
//             updated_at,
//             customizations (
//               customization_id,
//               item_id,
//               name,
//               type,
//               base_price,
//               is_required,
//               display_order,
//               created_at,
//               updated_at,
//               customization_options (
//                 option_id,
//                 customization_id,
//                 name,
//                 additional_price,
//                 display_order,
//                 created_at
//               )
//             )
//           ''')
//           .eq('hotel_id', restaurantId)
//           .eq('is_available', true)
//           .order('name', ascending: true);

//       return (response as List)
//           .map((json) => MenuItem.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch menu items: ${e.toString()}',
//         code: 'MENU_ITEMS_FETCH_ERROR',
//       );
//     }
//   }

//   /// Fetch menu items by category for a restaurant
//   Future<List<MenuItem>> fetchMenuItemsByCategory(
//     String restaurantId,
//     String category,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('''
//             item_id,
//             hotel_id,
//             name,
//             description,
//             price,
//             is_available,
//             category,
//             stock_quantity,
//             low_stock_threshold,
//             created_at,
//             updated_at,
//             customizations (
//               customization_id,
//               item_id,
//               name,
//               type,
//               base_price,
//               is_required,
//               display_order,
//               created_at,
//               updated_at,
//               customization_options (
//                 option_id,
//                 customization_id,
//                 name,
//                 additional_price,
//                 display_order,
//                 created_at
//               )
//             )
//           ''')
//           .eq('hotel_id', restaurantId)
//           .eq('category', category)
//           .eq('is_available', true)
//           .order('name', ascending: true);

//       return (response as List)
//           .map((json) => MenuItem.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch menu items by category: ${e.toString()}',
//         code: 'MENU_ITEMS_CATEGORY_ERROR',
//       );
//     }
//   }

//   /// Search menu items by name or description
//   Future<List<MenuItem>> searchMenuItems(
//     String restaurantId,
//     String query,
//   ) async {
//     if (query.isEmpty) return fetchMenuItemsByRestaurant(restaurantId);

//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('''
//             item_id,
//             hotel_id,
//             name,
//             description,
//             price,
//             is_available,
//             category,
//             stock_quantity,
//             low_stock_threshold,
//             created_at,
//             updated_at,
//             customizations (
//               customization_id,
//               item_id,
//               name,
//               type,
//               base_price,
//               is_required,
//               display_order,
//               created_at,
//               updated_at,
//               customization_options (
//                 option_id,
//                 customization_id,
//                 name,
//                 additional_price,
//                 display_order,
//                 created_at
//               )
//             )
//           ''')
//           .eq('hotel_id', restaurantId)
//           .eq('is_available', true)
//           .or('name.ilike.%$query%,description.ilike.%$query%')
//           .limit(20)
//           .order('name', ascending: true);

//       return (response as List)
//           .map((json) => MenuItem.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to search menu items: ${e.toString()}',
//         code: 'MENU_ITEMS_SEARCH_ERROR',
//       );
//     }
//   }

//   /// Get available categories for a restaurant
//   Future<List<String>> getMenuCategories(String restaurantId) async {
//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('category')
//           .eq('hotel_id', restaurantId)
//           .eq('is_available', true)
//           .not('category', 'is', null);

//       final categories = <String>{};
//       for (var item in response) {
//         if (item['category'] != null) {
//           categories.add(item['category'] as String);
//         }
//       }

//       return categories.toList()..sort();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch menu categories: ${e.toString()}',
//         code: 'MENU_CATEGORIES_ERROR',
//       );
//     }
//   }

//   /// Get single menu item with customizations
//   Future<MenuItem?> getMenuItemById(String restaurantId, String itemId) async {
//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('''
//             item_id,
//             hotel_id,
//             name,
//             description,
//             price,
//             is_available,
//             category,
//             stock_quantity,
//             low_stock_threshold,
//             created_at,
//             updated_at,
//             customizations (
//               customization_id,
//               item_id,
//               name,
//               type,
//               base_price,
//               is_required,
//               display_order,
//               created_at,
//               updated_at,
//               customization_options (
//                 option_id,
//                 customization_id,
//                 name,
//                 additional_price,
//                 display_order,
//                 created_at
//               )
//             )
//           ''')
//           .eq('hotel_id', restaurantId)
//           .eq('item_id', itemId)
//           .maybeSingle();

//       if (response == null) return null;

//       return MenuItem.fromJson(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch menu item details: ${e.toString()}',
//         code: 'MENU_ITEM_DETAIL_ERROR',
//       );
//     }
//   }

//   /// Get in-stock menu items only
//   Future<List<MenuItem>> getInStockMenuItems(String restaurantId) async {
//     try {
//       final response = await _supabase
//           .from('menu_items')
//           .select('''
//             item_id,
//             hotel_id,
//             name,
//             description,
//             price,
//             is_available,
//             category,
//             stock_quantity,
//             low_stock_threshold,
//             created_at,
//             updated_at,
//             customizations (
//               customization_id,
//               item_id,
//               name,
//               type,
//               base_price,
//               is_required,
//               display_order,
//               created_at,
//               updated_at,
//               customization_options (
//                 option_id,
//                 customization_id,
//                 name,
//                 additional_price,
//                 display_order,
//                 created_at
//               )
//             )
//           ''')
//           .eq('hotel_id', restaurantId)
//           .eq('is_available', true)
//           .gt('stock_quantity', 0)
//           .order('name', ascending: true);

//       return (response as List)
//           .map((json) => MenuItem.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch in-stock menu items: ${e.toString()}',
//         code: 'IN_STOCK_ITEMS_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // CUSTOMER METHODS
//   // ============================================================================

//   /// Fetch all existing customers
//   Future<List<UserModel>> fetchAllCustomers() async {
//     try {
//       final response = await _supabase
//           .from('profiles')
//           .select()
//           .eq('usertype', 'user')
//           .order('created_at', ascending: false);

//       return (response as List)
//           .map((json) => UserModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch customers: ${e.toString()}',
//         code: 'CUSTOMERS_FETCH_ERROR',
//       );
//     }
//   }

//   /// Search existing customers by name, email, or phone
//   Future<List<UserModel>> searchCustomers(String query) async {
//     if (query.isEmpty) return fetchAllCustomers();

//     try {
//       final response = await _supabase
//           .from('profiles')
//           .select()
//           .eq('usertype', 'user')
//           .or('name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%')
//           .limit(10)
//           .order('created_at', ascending: false);

//       return (response as List)
//           .map((json) => UserModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to search customers: ${e.toString()}',
//         code: 'CUSTOMER_SEARCH_ERROR',
//       );
//     }
//   }

//   /// Get customer by ID
//   Future<UserModel?> getCustomerById(String customerId) async {
//     try {
//       final response = await _supabase
//           .from('profiles')
//           .select()
//           .eq('id', customerId)
//           .eq('usertype', 'user')
//           .maybeSingle();

//       if (response == null) return null;

//       return UserModel.fromJson(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch customer: ${e.toString()}',
//         code: 'CUSTOMER_DETAIL_ERROR',
//       );
//     }
//   }

//   /// Create a new customer (quick creation during order)
//   Future<UserModel> createQuickCustomer({
//     required String name,
//     required String phone,
//     String? email,
//     String? address,
//   }) async {
//     try {
//       final response = await _supabase
//           .from('profiles')
//           .insert({
//             'name': name,
//             'phone': phone,
//             'email': email,
//             'address': address,
//             'usertype': 'user',
//             'created_at': DateTime.now().toIso8601String(),
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .select()
//           .single();

//       return UserModel.fromJson(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to create customer: ${e.toString()}',
//         code: 'CUSTOMER_CREATE_ERROR',
//       );
//     }
//   }

//   /// Get customers with pending payments
//   Future<List<UserModel>> getCustomersWithPendingPayments() async {
//     try {
//       final response = await _supabase
//           .from('profiles')
//           .select()
//           .eq('usertype', 'user')
//           .gt('pending_payments', 0)
//           .order('pending_payments', ascending: false);

//       return (response as List)
//           .map((json) => UserModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch customers with pending payments: ${e.toString()}',
//         code: 'PENDING_PAYMENTS_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // DELIVERY PERSONNEL METHODS
//   // ============================================================================

//   /// Fetch all available delivery personnel
//   Future<List<SimpleDeliveryPersonnel>> fetchAvailableDeliveryPersonnel() async {
//     try {
//       final response = await _supabase
//           .from('delivery_personnel')
//           .select()
//           .eq('is_available', true)
//           .eq('is_verified', true)
//           .order('created_at', ascending: false);

//       return (response as List)
//           .map((json) => SimpleDeliveryPersonnel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch delivery personnel: ${e.toString()}',
//         code: 'DELIVERY_PERSONNEL_FETCH_ERROR',
//       );
//     }
//   }

//   /// Search delivery personnel
//   Future<List<SimpleDeliveryPersonnel>> searchDeliveryPersonnel({
//     String? searchQuery,
//     bool? isAvailable,
//     bool? isVerified,
//   }) async {
//     try {
//       var query = _supabase.from('delivery_personnel').select();

//       if (isAvailable != null) {
//         query = query.eq('is_available', isAvailable);
//       }

//       if (isVerified != null) {
//         query = query.eq('is_verified', isVerified);
//       }

//       if (searchQuery != null && searchQuery.isNotEmpty) {
//         query = query.or(
//           'name.ilike.%$searchQuery%,'
//           'full_name.ilike.%$searchQuery%,'
//           'email.ilike.%$searchQuery%,'
//           'phone.ilike.%$searchQuery%',
//         );
//       }

//       final response = await query.order('created_at', ascending: false);

//       return (response as List)
//           .map((json) => SimpleDeliveryPersonnel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to search delivery personnel: ${e.toString()}',
//         code: 'DELIVERY_SEARCH_ERROR',
//       );
//     }
//   }

//   /// Get delivery personnel by location (city)
//   Future<List<SimpleDeliveryPersonnel>> getDeliveryPersonnelByLocation(
//     String city,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('delivery_personnel')
//           .select()
//           .eq('city', city)
//           .eq('is_available', true)
//           .eq('is_verified', true)
//           .order('created_at', ascending: false);

//       return (response as List)
//           .map((json) => SimpleDeliveryPersonnel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch delivery personnel by location: ${e.toString()}',
//         code: 'DELIVERY_LOCATION_ERROR',
//       );
//     }
//   }

//   /// Get delivery personnel by state
//   Future<List<SimpleDeliveryPersonnel>> getDeliveryPersonnelByState(
//     String state,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('delivery_personnel')
//           .select()
//           .eq('state', state)
//           .eq('is_available', true)
//           .eq('is_verified', true)
//           .order('city', ascending: true);

//       return (response as List)
//           .map((json) => SimpleDeliveryPersonnel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch delivery personnel by state: ${e.toString()}',
//         code: 'DELIVERY_STATE_ERROR',
//       );
//     }
//   }

//   /// Get delivery personnel by ID
//   Future<SimpleDeliveryPersonnel?> getDeliveryPersonnelById(
//     String userId,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('delivery_personnel')
//           .select()
//           .eq('user_id', userId)
//           .maybeSingle();

//       if (response == null) return null;

//       return SimpleDeliveryPersonnel.fromJson(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch delivery personnel: ${e.toString()}',
//         code: 'DELIVERY_DETAIL_ERROR',
//       );
//     }
//   }

//   /// Get least busy delivery personnel
//   Future<SimpleDeliveryPersonnel?> getLeastBusyDeliveryPersonnel({
//     String? city,
//   }) async {
//     try {
//       var query = _supabase.from('delivery_personnel').select();

//       if (city != null) {
//         query = query.eq('city', city);
//       }

//       final response = await query
//           .eq('is_available', true)
//           .eq('is_verified', true)
//           .order('assigned_orders', ascending: true)
//           .limit(1);

//       if ((response as List).isEmpty) return null;

//       return SimpleDeliveryPersonnel.fromJson(response[0]);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch least busy delivery personnel: ${e.toString()}',
//         code: 'DELIVERY_LEAST_BUSY_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // ORDER ASSIGNMENT METHODS
//   // ============================================================================

//   /// Assign order to delivery personnel
//   Future<bool> assignOrderToDeliveryPersonnel(
//     String orderId,
//     String deliveryPersonId,
//   ) async {
//     try {
//       final deliveryPersonResponse = await _supabase
//           .from('delivery_personnel')
//           .select('assigned_orders')
//           .eq('user_id', deliveryPersonId)
//           .single();

//       List<String> currentOrders = List<String>.from(
//         deliveryPersonResponse['assigned_orders'] ?? [],
//       );

//       if (!currentOrders.contains(orderId)) {
//         currentOrders.add(orderId);
//       }

//       await _supabase
//           .from('delivery_personnel')
//           .update({
//             'assigned_orders': currentOrders,
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('user_id', deliveryPersonId);

//       await _supabase
//           .from('orders')
//           .update({
//             'delivery_person_id': deliveryPersonId,
//             'delivery_status': 'Assigned',
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('order_id', orderId);

//       return true;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to assign order to delivery personnel: ${e.toString()}',
//         code: 'ASSIGN_ORDER_ERROR',
//       );
//     }
//   }

//   /// Unassign order from delivery personnel
//   Future<bool> unassignOrderFromDeliveryPersonnel(
//     String orderId,
//     String? deliveryPersonId,
//   ) async {
//     try {
//       if (deliveryPersonId != null) {
//         final deliveryPersonResponse = await _supabase
//             .from('delivery_personnel')
//             .select('assigned_orders')
//             .eq('user_id', deliveryPersonId)
//             .single();

//         List<String> currentOrders = List<String>.from(
//           deliveryPersonResponse['assigned_orders'] ?? [],
//         );

//         currentOrders.remove(orderId);

//         await _supabase
//             .from('delivery_personnel')
//             .update({
//               'assigned_orders': currentOrders,
//               'updated_at': DateTime.now().toIso8601String(),
//             })
//             .eq('user_id', deliveryPersonId);
//       }

//       await _supabase
//           .from('orders')
//           .update({
//             'delivery_person_id': null,
//             'delivery_status': 'Pending',
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('order_id', orderId);

//       return true;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to unassign order from delivery personnel: ${e.toString()}',
//         code: 'UNASSIGN_ORDER_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // ORDER ITEM METHODS (Uncommented & Enhanced)
//   // ============================================================================

//   /// Create multiple order items with customizations
//   Future<List<Map<String, dynamic>>> createOrderItems(
//     List<Map<String, dynamic>> orderItems,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('order_items')
//           .insert(orderItems)
//           .select();

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to create order items: ${e.toString()}',
//         code: 'ORDER_ITEMS_CREATE_ERROR',
//       );
//     }
//   }

//   /// Get all order items for a specific order with menu item names
//   Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
//     try {
//       final response = await _supabase
//           .from('order_items')
//           .select('''
//             *,
//             menu_items!fk_menu_item(name)
//           ''')
//           .eq('order_id', orderId);

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to load order items: ${e.toString()}',
//         code: 'ORDER_ITEMS_FETCH_ERROR',
//       );
//     }
//   }

//   /// Get a single order item
//   Future<Map<String, dynamic>?> getOrderItem(
//     String orderId,
//     String itemId,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('order_items')
//           .select('''
//             *,
//             menu_items!fk_menu_item(name)
//           ''')
//           .eq('order_id', orderId)
//           .eq('item_id', itemId)
//           .maybeSingle();

//       return response;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to load order item: ${e.toString()}',
//         code: 'ORDER_ITEM_FETCH_ERROR',
//       );
//     }
//   }

//   /// Update an order item
//   Future<Map<String, dynamic>?> updateOrderItem(
//     String orderId,
//     String itemId,
//     Map<String, dynamic> updates,
//   ) async {
//     try {
//       final response = await _supabase
//           .from('order_items')
//           .update(updates)
//           .eq('order_id', orderId)
//           .eq('item_id', itemId)
//           .select()
//           .single();

//       return response;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to update order item: ${e.toString()}',
//         code: 'ORDER_ITEM_UPDATE_ERROR',
//       );
//     }
//   }

//   /// Delete a specific order item
//   Future<bool> deleteOrderItem(String orderId, String itemId) async {
//     try {
//       await _supabase
//           .from('order_items')
//           .delete()
//           .eq('order_id', orderId)
//           .eq('item_id', itemId);

//       return true;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to delete order item: ${e.toString()}',
//         code: 'ORDER_ITEM_DELETE_ERROR',
//       );
//     }
//   }

//   /// Delete all order items for a specific order
//   Future<bool> deleteOrderItems(String orderId) async {
//     try {
//       await _supabase
//           .from('order_items')
//           .delete()
//           .eq('order_id', orderId);

//       return true;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to delete order items: ${e.toString()}',
//         code: 'ORDER_ITEMS_DELETE_ERROR',
//       );
//     }
//   }

//   /// Calculate total amount for an order
//   Future<double> calculateOrderTotal(String orderId) async {
//     try {
//       final orderItems = await getOrderItems(orderId);
//       return orderItems.fold<double>(0.0, (sum, item) {
//         final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//         final customizationPrice =
//             (item['customization_additional_price'] as num?)?.toDouble() ?? 0.0;
//         final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
//         return sum + ((price + customizationPrice) * quantity);
//       });
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to calculate order total: ${e.toString()}',
//         code: 'ORDER_TOTAL_ERROR',
//       );
//     }
//   }

//   /// Get order items count for a specific order
//   Future<int> getOrderItemsCount(String orderId) async {
//     try {
//       final response = await _supabase
//           .from('order_items')
//           .select('order_id')
//           .eq('order_id', orderId);

//       return (response as List).length;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to get order items count: ${e.toString()}',
//         code: 'ORDER_ITEMS_COUNT_ERROR',
//       );
//     }
//   }

//   /// Bulk update order items
//   Future<List<Map<String, dynamic>>> updateOrderItems(
//     List<Map<String, dynamic>> orderItems,
//   ) async {
//     try {
//       List<Map<String, dynamic>> updatedItems = [];

//       for (Map<String, dynamic> item in orderItems) {
//         final updated = await updateOrderItem(
//           item['order_id'],
//           item['item_id'],
//           item,
//         );
//         if (updated != null) {
//           updatedItems.add(updated);
//         }
//       }

//       return updatedItems;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to bulk update order items: ${e.toString()}',
//         code: 'ORDER_ITEMS_BULK_UPDATE_ERROR',
//       );
//     }
//   }

//   /// Get order item details with all customization info
//   Future<Map<String, dynamic>?> getOrderItemDetails(
//     String orderId,
//     String itemId,
//   ) async {
//     try {
//       final itemResponse = await getOrderItem(orderId, itemId);

//       if (itemResponse == null) return null;

//       return {
//         'order_id': itemResponse['order_id'],
//         'item_id': itemResponse['item_id'],
//         'item_name': itemResponse['menu_items']?['name'],
//         'quantity': itemResponse['quantity'],
//         'base_price': itemResponse['price'],
//         'customization_price': itemResponse['customization_additional_price'],
//         'total_price': (((itemResponse['price'] as num?)?.toDouble() ?? 0.0) +
//                 ((itemResponse['customization_additional_price'] as num?)
//                         ?.toDouble() ??
//                     0.0)) *
//             (itemResponse['quantity'] as int? ?? 1),
//       };
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to get order item details: ${e.toString()}',
//         code: 'ORDER_ITEM_DETAILS_ERROR',
//       );
//     }
//   }

//   // ============================================================================
//   // HELPER METHODS
//   // ============================================================================

//   /// Get all data needed for order creation in one call (optimized)
//   Future<Map<String, dynamic>> getAllOrderCreationData({
//     String? restaurantId,
//   }) async {
//     try {
//       final futures = [
//         fetchAllRestaurants(),
//         fetchAllCustomers(),
//         fetchAvailableDeliveryPersonnel(),
//       ];

//       final results = await Future.wait(futures);

//       final Map<String, dynamic> data = {
//         'restaurants': results[0],
//         'customers': results[1],
//         'deliveryPersonnel': results[2],
//       };

//       if (restaurantId != null) {
//         data['menuItems'] = await fetchMenuItemsByRestaurant(restaurantId);
//         data['categories'] = await getMenuCategories(restaurantId);
//       }

//       return data;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to fetch order creation data: ${e.toString()}',
//         code: 'ORDER_CREATION_DATA_ERROR',
//       );
//     }
//   }

//   /// Validate menu item availability and stock
//   Future<bool> validateMenuItemStock(
//     String restaurantId,
//     String itemId,
//     int quantity,
//   ) async {
//     try {
//       final menuItem = await getMenuItemById(restaurantId, itemId);

//       if (menuItem == null || !menuItem.isAvailable) {
//         throw AddOrderException(
//           message: 'Menu item is not available',
//           code: 'ITEM_NOT_AVAILABLE',
//         );
//       }

//       if (menuItem.stockQuantity < quantity) {
//         throw AddOrderException(
//           message:
//               'Insufficient stock. Available: ${menuItem.stockQuantity}, Requested: $quantity',
//           code: 'INSUFFICIENT_STOCK',
//         );
//       }

//       return true;
//     } catch (e) {
//       throw AddOrderException(
//         message: 'Failed to validate menu item stock: ${e.toString()}',
//         code: 'STOCK_VALIDATION_ERROR',
//       );
//     }
//   }

//   /// Stream restaurants for real-time updates
//   Stream<List<Map<String, dynamic>>> streamRestaurants() {
//     return _supabase
//         .from('hotels')
//         .stream(primaryKey: ['hotel_id'])
//         .order('name', ascending: true)
//         .map((data) => List<Map<String, dynamic>>.from(data));
//   }

//   /// Stream menu items for a restaurant
//   Stream<List<MenuItem>> streamMenuItems(String restaurantId) {
//     return _supabase
//         .from('menu_items')
//         .stream(primaryKey: ['item_id'])
//         .eq('hotel_id', restaurantId)
//         .order('name', ascending: true)
//         .map((data) => (data as List)
//             .map((json) => MenuItem.fromJson(json))
//             .toList());
//   }

//   /// Stream available delivery personnel
//   Stream<List<SimpleDeliveryPersonnel>> streamAvailableDeliveryPersonnel() {
//     return _supabase
//         .from('delivery_personnel')
//         .stream(primaryKey: ['user_id'])
//         .eq('is_available', true)
//         .order('created_at', ascending: false)
//         .map((data) => (data as List)
//             .map((json) => SimpleDeliveryPersonnel.fromJson(json))
//             .toList());
//   }
// }