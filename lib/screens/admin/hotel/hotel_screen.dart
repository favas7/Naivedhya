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

  void _showAddHotelDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddHotelDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hotels.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
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
                    Icons.hotel_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first hotel by tapping the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.loadHotels(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.hotels.length,
              itemBuilder: (context, index) {
                final hotel = provider.hotels[index];
                return HotelCard(hotel: hotel);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHotelDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
