import 'package:flutter/material.dart';
import 'package:naivedhya/models/hotel.dart';

class HotelCardMetaInfo extends StatelessWidget {
  final Hotel hotel;

  const HotelCardMetaInfo({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    if (hotel.createdAt == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          'Created: ${_formatDate(hotel.createdAt!)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}