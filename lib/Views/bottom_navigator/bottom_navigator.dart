import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/Views/user/home/customer_care_screen.dart';
import 'package:naivedhya/Views/user/home/favorites_screen.dart';
import 'package:naivedhya/Views/user/home/food_screen.dart';
import 'package:naivedhya/Views/user/home/home_screen.dart';
import 'package:naivedhya/Views/user/home/list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
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
        selectedItemColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
        unselectedItemColor: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}