import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:naivedhya/Views/admin/restaurant/restaurant_screen.dart';
import 'package:naivedhya/providers/auth_provider.dart';
import 'package:naivedhya/providers/theme_provider.dart';
import 'package:naivedhya/Views/admin/analytics/analatics_screen.dart';
import 'package:naivedhya/Views/admin/customer/customer_screen.dart';
import 'package:naivedhya/Views/admin/dashboard/dashboard.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_staff_screen.dart';
import 'package:naivedhya/Views/admin/map/map_screen.dart';
import 'package:naivedhya/Views/admin/notification/notification_screen.dart';
import 'package:naivedhya/Views/admin/order/order_screen.dart';
import 'package:naivedhya/Views/admin/payment/payment_screen.dart';
import 'package:naivedhya/Views/admin/pos/pos_integration_screen.dart';
import 'package:naivedhya/Views/admin/settings/settings_screen.dart';
import 'package:naivedhya/Views/admin/vendors/vendors_screen.dart';
import 'package:naivedhya/Views/auth/login/login_screen.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _menuItems = [
    'Dashboard',
    'Live Map',
    'Orders',
    'Restaurants',
    'Vendors',
    'Delivery Staff',
    'Customers',
    'Payments',
    'Ananlytics',
    'POS integration',
    'Notification',
    'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    final _ = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey[100],
      drawer: !isDesktop ? _buildDrawer(isDark) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar for desktop
            if (isDesktop) _buildSidebar(isDark),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 60,
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (!isDesktop)
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        Text(
                          _menuItems[_selectedIndex],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 250,
      color: isDark ? AppTheme.darkSurface : AppTheme.primary,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppTheme.darkDivider : Colors.white24),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (isDark ? AppTheme.darkPrimary.withOpacity(0.3) : Colors.white.withOpacity(0.1))
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForMenuItem(index),
                      color: Colors.white,
                    ),
                    title: Text(
                      _menuItems[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Logout Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _logout(isDark);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkError : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      child: Container(
        color: isDark ? AppTheme.darkSurface : AppTheme.primary,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppTheme.darkDivider : Colors.white24),
            // Menu Items
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (isDark ? AppTheme.darkPrimary.withOpacity(0.3) : Colors.white.withOpacity(0.1))
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconForMenuItem(index),
                        color: Colors.white,
                      ),
                      title: Text(
                        _menuItems[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context); // Close drawer after selection
                      },
                    ),
                  );
                },
              ),
            ),
            // Logout Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close drawer first
                    _logout(isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.darkError : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMenuItem(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.location_on;
      case 2:
        return Icons.shopping_cart;
      case 3:
        return Icons.home_work_outlined;
      case 4:
        return Icons.playlist_add_check;
      case 5:
        return Icons.delivery_dining;
      case 6:
        return Icons.man;
      case 7:
        return Icons.payment;
      case 8:
        return Icons.analytics;
      case 9:
        return Icons.polyline_sharp;
      case 10:
        return Icons.notifications_active;
      case 11:
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const MapScreen();
      case 2:
        return const OrdersScreen();
      case 3:
        return const RestaurantScreen();
      case 4:
        return const VendorScreen();
      case 5:
        return const DeliveryStaffScreen();
      case 6:
        return const CustomerScreen();
      case 7:
        return const PaymentScreen();
      case 8:
        return const AnalyticsScreen();
      case 9:
        return const POSIntegrationScreen();
      case 10:
        return const NotificationScreen();
      case 11:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _logout(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: isDark ? AppTheme.darkError : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}