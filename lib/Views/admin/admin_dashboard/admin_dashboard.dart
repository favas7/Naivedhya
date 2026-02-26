import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:naivedhya/providers/auth_provider.dart';
import 'package:naivedhya/providers/theme_provider.dart';
// import 'package:naivedhya/Views/admin/analytics/analatics_screen.dart';  // ❌ COMMENTED OUT
import 'package:naivedhya/Views/admin/customer/customer_screen.dart';
import 'package:naivedhya/Views/admin/dashboard/dashboard.dart';
import 'package:naivedhya/Views/admin/delivery_staff/delivery_staff_screen.dart';
import 'package:naivedhya/Views/admin/map/map_screen.dart';
// import 'package:naivedhya/Views/admin/menu/menu_screen.dart';             // ❌ COMMENTED OUT
import 'package:naivedhya/Views/admin/notification/notification_screen.dart';
import 'package:naivedhya/Views/admin/order/order_screen.dart';
// import 'package:naivedhya/Views/admin/payment/payment_screen.dart';       // ❌ COMMENTED OUT
import 'package:naivedhya/Views/admin/pos/pos_integration_screen.dart';
import 'package:naivedhya/Views/admin/settings/settings_screen.dart';
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

  // ✅ Your Naivedhya restaurant ID
  // static const String _hotelId = 'eda88a9c-b223-4f8e-ab4f-87b32f062b84'; // ❌ COMMENTED OUT (used only by MenuScreen)

  final List<String> _menuItems = [
    'Dashboard',      // 0
    'Live Map',       // 1
    'Orders',         // 2
    // 'Menu Management', // ❌ COMMENTED OUT
    'Delivery Staff', // 3
    'Customers',      // 4
    // 'Payments',     // ❌ COMMENTED OUT
    // 'Analytics',    // ❌ COMMENTED OUT
    'POS Integration',// 5
    'Notification',   // 6
    'Settings'        // 7
  ];

  @override
  Widget build(BuildContext context) {
    final _ = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colors = AppTheme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: !isDesktop ? _buildDrawer(isDark, colors) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar for desktop
            if (isDesktop) _buildSidebar(isDark, colors),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(isDesktop, isDark, colors),
                  // Content Area
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop, bool isDark, AppThemeColors colors) {
    return Container(
      height: 60,
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: Icon(
                Icons.menu,
                color: colors.textPrimary,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          Text(
            _menuItems[_selectedIndex],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.textPrimary,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: colors.textPrimary,
            ),
            onPressed: () {
              // Navigate to notifications
              setState(() {
                _selectedIndex = 6; // Notification index (updated)
              });
            },
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: colors.primary,
            child: const Icon(
              Icons.person,
              color: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark, AppThemeColors colors) {
    return Container(
      width: 250,
      color: colors.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: isDark ? AppTheme.darkBackground : AppTheme.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Naivedhya Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: colors.textSecondary.withOpacity(0.2),
            height: 1,
          ),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary.withOpacity(0.15) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForMenuItem(index),
                      color: isSelected ? colors.primary : colors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      _menuItems[index],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? colors.primary : colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
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
              child: ElevatedButton.icon(
                onPressed: () {
                  _logout(isDark, colors);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark, AppThemeColors colors) {
    return Drawer(
      child: Container(
        color: colors.surface,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primary,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: isDark ? AppTheme.darkBackground : AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Naivedhya Admin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: colors.textSecondary.withOpacity(0.2),
              height: 1,
            ),
            // Menu Items
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withOpacity(0.15) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconForMenuItem(index),
                        color: isSelected ? colors.primary : colors.textSecondary,
                        size: 22,
                      ),
                      title: Text(
                        _menuItems[index],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? colors.primary : colors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _logout(isDark, colors);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
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
      // case 3: Icons.restaurant_menu  // ❌ COMMENTED OUT - Menu Management
      case 3:
        return Icons.delivery_dining;
      case 4:
        return Icons.people;
      // case 5: Icons.payment          // ❌ COMMENTED OUT - Payments
      // case 6: Icons.analytics        // ❌ COMMENTED OUT - Analytics
      case 5:
        return Icons.point_of_sale;
      case 6:
        return Icons.notifications_active;
      case 7:
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
      // case 3: return MenuScreen(hotelId: _hotelId);  // ❌ COMMENTED OUT - Menu Management
      case 3:
        return const DeliveryStaffScreen();
      case 4:
        return const CustomerScreen();
      // case 5: return const PaymentScreen();          // ❌ COMMENTED OUT - Payments
      // case 6: return const AnalyticsScreen();        // ❌ COMMENTED OUT - Analytics
      case 5:
        return const POSIntegrationScreen();
      case 6:
        return const NotificationScreen();
      case 7:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _logout(bool isDark, AppThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
              ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}