import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String selectedFilter = 'All';
  bool showDeliveryStaff = true;
  bool showCustomers = true;
  bool showRestaurants = true;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 480 && screenWidth <= 768;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Location Tracking',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Real-time tracking of delivery staff, customers, and Restaurants',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Controls and Map Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Control Panel
              if (isDesktop) 
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: _buildControlPanel(theme),
                ),
              
              // Map Container
              Expanded(
                child: _buildMapContainer(theme, isDesktop, isTablet),
              ),
            ],
          ),
          
          // Mobile Control Panel
          if (!isDesktop) ...[
            const SizedBox(height: 20),
            _buildControlPanel(theme),
          ],
          
          const SizedBox(height: 20),
          
          // Statistics Cards
          _buildStatisticsCards(theme, isDesktop, isTablet),
          
          const SizedBox(height: 20),
          
          // Recent Activity
          _buildRecentActivity(theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildControlPanel(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Map Controls',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          
          // Filter Dropdown
          DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'Delivering', child: Text('Delivering')),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Toggle Switches
          Text(
            'Show on Map',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          
          SwitchListTile(
            title: const Text('Delivery Staff'),
            subtitle: Text(
              'Active delivery personnel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showDeliveryStaff,
            onChanged: (value) {
              setState(() {
                showDeliveryStaff = value;
              });
            },
            activeColor: theme.primary,
          ),
          
          SwitchListTile(
            title: const Text('Customers'),
            subtitle: Text(
              'Customer locations',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showCustomers,
            onChanged: (value) {
              setState(() {
                showCustomers = value;
              });
            },
            activeColor: theme.primary,
          ),
          
          SwitchListTile(
            title: const Text('Restaurants'),
            subtitle: Text(
              'Partner Restaurants',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showRestaurants,
            onChanged: (value) {
              setState(() {
                showRestaurants = value;
              });
            },
            activeColor: theme.primary,
          ),
          
          const SizedBox(height: 20),
          
          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Refresh map data
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer(AppThemeColors theme, bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 500 : 400,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Map placeholder
            Container(
              color: theme.isDark 
                ? AppTheme.darkSurfaceVariant 
                : Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 64,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Map View',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Integrate with Google Maps or similar service',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Map Legend
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legend',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(theme.info, 'Delivery Staff'),
                    _buildLegendItem(theme.success, 'Customers'),
                    _buildLegendItem(theme.warning, 'Restaurants'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(AppThemeColors theme, bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 2 : 3),
      children: [
        _buildStatCard(theme, 'Active Delivery Staff', '24', Icons.delivery_dining, theme.info),
        _buildStatCard(theme, 'Online Customers', '156', Icons.people, theme.success),
        _buildStatCard(theme, 'Partner Restaurants', '48', Icons.restaurant, theme.warning),
        _buildStatCard(theme, 'Active Orders', '32', Icons.shopping_cart, theme.error),
      ],
    );
  }

  Widget _buildStatCard(AppThemeColors theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AppThemeColors theme, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              color: theme.textSecondary.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.location_on,
                    color: theme.primary,
                  ),
                ),
                title: Text(
                  'Delivery Staff #${index + 1} location updated',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '${index + 1} minutes ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 