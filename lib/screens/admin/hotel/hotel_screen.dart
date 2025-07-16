import 'package:flutter/material.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:naivedhya/screens/admin/hotel/widgets/add_hotel_dialog.dart';
import 'package:provider/provider.dart';


class HotelScreen extends StatelessWidget {
  const HotelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HotelProvider()..fetchHotels(),
      child: const HotelScreenContent(),
    );
  }
}

class HotelScreenContent extends StatelessWidget {
  const HotelScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHotelDialog(context),
          ),
        ],
      ),
      body: Consumer<HotelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchHotels(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.hotels.length,
            itemBuilder: (context, index) {
              final hotel = provider.hotels[index];
              return ListTile(
                title: Text(hotel.name),
                subtitle: Text(hotel.address),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddHotelDialog(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    provider.clearAllControllers();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: provider,
        child: const AddHotelDialog(),
      ),
    );
  }
}