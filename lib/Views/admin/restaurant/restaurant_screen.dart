import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/add_hotel_dialogue.dart';
import 'package:naivedhya/Views/admin/restaurant/widgets/hotel_card.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import 'package:provider/provider.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => RestaurantProvider(),
      child: const RestaurantScreenContent(),
    );
  }
}

class RestaurantScreenContent extends StatefulWidget {
  const RestaurantScreenContent({super.key});

  @override
  State<RestaurantScreenContent> createState() => _RestaurantScreenContentState();
}

class _RestaurantScreenContentState extends State<RestaurantScreenContent> {
  @override
  void initState() {
    super.initState();
    // Load Restaurants when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
    });
  }

  void _showAddRestaurantDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddRestaurantDialog(),
    );
    
    // Refresh the Restaurant list if a new Restaurant was added
    if (result == true && mounted) {
      Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
    }
  }

  void _refreshRestaurants() {
    Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Removed the leading property to hide the back button
        automaticallyImplyLeading: false,
        actions: [
          // Refresh button
          IconButton(
            onPressed: _refreshRestaurants,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.restaurants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Restaurants...'),
                ],
              ),
            );
          }

          if (provider.error != null && provider.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRestaurants(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Restaurants found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first Restaurant by tapping the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddRestaurantDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Restaurant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.loadRestaurants(),
            color: AppColors.primary,
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.restaurants[index];
                    return ExpandableRestaurantCard(
                      restaurant: restaurant,
                      onRestaurantUpdated: _refreshRestaurants,
                    );
                  },
                ),
                
                // Loading overlay when refreshing
                if (provider.isLoading && provider.restaurants.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 3,
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRestaurantDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Add Restaurant',
        child: const Icon(Icons.add),
      ),
    );
  }
}