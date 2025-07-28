import 'package:flutter/material.dart';
import 'package:naivedhya/models/hotel.dart';

class HotelCardBasicInfo extends StatelessWidget {
  final Hotel hotel;

  const HotelCardBasicInfo({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    if (hotel.adminEmail == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 14,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Admin: ${hotel.adminEmail}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}