import 'package:flutter/material.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import 'package:naivedhya/screens/user/home/customer_care_screen.dart';
import 'package:naivedhya/screens/user/home/favorites_screen.dart';
import 'package:naivedhya/screens/user/home/food_screen.dart';
import 'package:naivedhya/screens/user/home/home_screen.dart';
import 'package:naivedhya/screens/user/home/list_screen.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FoodScreen(),
    const FavoritesScreen(),
    const ListScreen(),
    const CustomerCareScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: AppColors.white,
      ),
    );
  }
}