import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_hotel_dialogue.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/hotel_card.dart';
import 'package:provider/provider.dart';

class HotelScreen extends StatelessWidget {
  const HotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => HotelProvider(),
      child: const HotelScreenContent(),
    );
  }
}

class HotelScreenContent extends StatefulWidget {
  const HotelScreenContent({super.key});

  @override
  State<HotelScreenContent> createState() => _HotelScreenContentState();
}

class _HotelScreenContentState extends State<HotelScreenContent> {
  @override
  void initState() {
    super.initState();
    // Load hotels when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false).loadHotels();
    });
  }

  void _showAddHotelDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddHotelDialog(),
    );
    
    // Refresh the hotel list if a new hotel was added
    if (result == true && mounted) {
      Provider.of<HotelProvider>(context, listen: false).loadHotels();
    }
  }

  void _refreshHotels() {
    Provider.of<HotelProvider>(context, listen: false).loadHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            onPressed: _refreshHotels,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hotels.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading hotels...'),
                ],
              ),
            );
          }

          if (provider.error != null && provider.hotels.isEmpty) {
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
                    onPressed: () => provider.loadHotels(),
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

          if (provider.hotels.isEmpty) {
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
                    'No hotels found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first hotel by tapping the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddHotelDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Hotel'),
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
            onRefresh: () async => provider.loadHotels(),
            color: AppColors.primary,
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = provider.hotels[index];
                    return ExpandableHotelCard(
                      hotel: hotel,
                      onHotelUpdated: _refreshHotels,
                    );
                  },
                ),
                
                // Loading overlay when refreshing
                if (provider.isLoading && provider.hotels.isNotEmpty)
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
        onPressed: _showAddHotelDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Add Hotel',
        child: const Icon(Icons.add),
      ),
    );
  }
}