import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class PetpoojaProviderScreen extends StatelessWidget {
  const PetpoojaProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme, isDesktop),
          const SizedBox(height: 20),
          _buildAbout(context, theme, isDesktop),
          const SizedBox(height: 20),
          _buildKeyFeatures(context, theme, isDesktop),
          const SizedBox(height: 20),
          _buildIntegrations(context, theme, isDesktop),
          const SizedBox(height: 20),
          _buildSupportedOutlets(context, theme, isDesktop),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppThemeColors theme, bool isDesktop) {
    return _card(
      theme,
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.primary.withOpacity(0.25)),
            ),
            child: Center(
              child: Text(
                'PP',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Petpooja',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: isDesktop ? 26 : 22,
                          ),
                    ),
                    const SizedBox(width: 10),
                    _chip(context, theme, 'Active', theme.success),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Restaurant POS & Management System',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── About ──────────────────────────────────────────────────────────────────

  Widget _buildAbout(BuildContext context, AppThemeColors theme, bool isDesktop) {
    final stats = [
      {'label': 'Restaurants', 'value': '1,00,000+'},
      {'label': 'Cities', 'value': '200+'},
      {'label': 'Integrations', 'value': '200+'},
      {'label': 'Reports', 'value': '80+'},
    ];

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Petpooja is a cloud-based restaurant POS and management system trusted by over 1,00,000 outlets across India, UAE, and South Africa. It handles billing, orders, menus, inventory, staff, and payments — all from a single screen. Available on Android and iOS, it works online and offline.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.textSecondary,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 2.2 : 2.4,
            children: stats.map((s) => _statTile(context, theme, s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statTile(BuildContext context, AppThemeColors theme, Map<String, String> s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            s['value']!,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: theme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s['label']!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  // ── Key Features ───────────────────────────────────────────────────────────

  Widget _buildKeyFeatures(BuildContext context, AppThemeColors theme, bool isDesktop) {
    final features = [
      {
        'icon': Icons.receipt_long,
        'title': 'Billing & KOT',
        'desc': '3-click billing, KOT generation, bill splitting, table merging, discounts & coupons.',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Inventory Management',
        'desc': 'Item-wise auto deduction, low-stock alerts, day-end inventory & recipe cost tracking.',
      },
      {
        'icon': Icons.smartphone_outlined,
        'title': 'Online Order Management',
        'desc': 'Accept and manage Zomato, Swiggy & other aggregator orders from one screen.',
      },
      {
        'icon': Icons.bar_chart_outlined,
        'title': 'Reports & Analytics',
        'desc': '80+ reports: day-end sales, staff actions, GST, inventory consumption, and more.',
      },
      {
        'icon': Icons.menu_book_outlined,
        'title': 'Menu Management',
        'desc': 'Create menus, toggle items on/off, manage prices across all aggregators at once.',
      },
      {
        'icon': Icons.people_outline,
        'title': 'CRM & Loyalty',
        'desc': 'Customer order history, loyalty reward points, segmentation & outreach tools.',
      },
      {
        'icon': Icons.table_restaurant_outlined,
        'title': 'Table Management',
        'desc': 'Table reservations, waitlists, seating arrangements and turnover optimisation.',
      },
      {
        'icon': Icons.manage_accounts_outlined,
        'title': 'Role Management',
        'desc': 'Role-based access control for staff with activity reports to prevent pilferage.',
      },
    ];

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Features', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 2 : 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 3.8 : 4.2,
            children: features
                .map((f) => _featureTile(context, theme, f))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(BuildContext context, AppThemeColors theme, Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.isDark ? AppTheme.darkSurfaceVariant : const Color(0xFFF9F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(f['icon'] as IconData, size: 20, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  f['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  f['desc'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Integrations ───────────────────────────────────────────────────────────

  Widget _buildIntegrations(BuildContext context, AppThemeColors theme, bool isDesktop) {
    final categories = [
      {
        'label': 'Food Aggregators',
        'items': ['Zomato', 'Swiggy', 'Dunzo', 'Dineout', 'Uber Eats'],
      },
      {
        'label': 'Payments',
        'items': ['Paytm', 'PhonePe', 'Google Pay', 'Razorpay', 'UPI'],
      },
      {
        'label': 'Accounting & ERP',
        'items': ['Tally', 'AWS'],
      },
      {
        'label': 'Delivery & Logistics',
        'items': ['Dunzo', 'Shadowfax', 'Pidge', 'Tookan'],
      },
      {
        'label': 'Loyalty & CRM',
        'items': ['OptCulture', 'Reelo', 'Zipler.io'],
      },
    ];

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Integrations', style: Theme.of(context).textTheme.headlineMedium),
              ),
              _chip(context, theme, '200+ total', theme.info),
            ],
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (cat['items'] as List<String>)
                          .map((item) => _tag(context, theme, item))
                          .toList(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Supported Outlet Types ─────────────────────────────────────────────────

  Widget _buildSupportedOutlets(BuildContext context, AppThemeColors theme, bool isDesktop) {
    final outlets = [
      {'icon': Icons.restaurant, 'label': 'Fine Dine'},
      {'icon': Icons.fastfood, 'label': 'QSR'},
      {'icon': Icons.local_cafe, 'label': 'Cafe'},
      {'icon': Icons.food_bank, 'label': 'Food Court'},
      {'icon': Icons.kitchen, 'label': 'Cloud Kitchen'},
      {'icon': Icons.cake, 'label': 'Bakery'},
      {'icon': Icons.local_bar, 'label': 'Bar & Brewery'},
      {'icon': Icons.store, 'label': 'Large Chain'},
    ];

    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supported Outlet Types', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 2.8 : 3.2,
            children: outlets
                .map((o) => _outletTile(context, theme, o))
                .toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.textSecondary.withOpacity(0.15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.support_agent, size: 18, color: theme.success),
              const SizedBox(width: 8),
              Text(
                '24×7 support  ·  Offline mode  ·  Android & iOS  ·  India, UAE & South Africa',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outletTile(BuildContext context, AppThemeColors theme, Map<String, dynamic> o) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.isDark ? AppTheme.darkSurfaceVariant : const Color(0xFFF9F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.textSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(o['icon'] as IconData, size: 18, color: theme.primary),
          const SizedBox(width: 8),
          Text(
            o['label'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  // ── Shared Helpers ─────────────────────────────────────────────────────────

  Widget _card(AppThemeColors theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _chip(BuildContext context, AppThemeColors theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, AppThemeColors theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.isDark ? AppTheme.darkSurfaceVariant : const Color(0xFFF9F6F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.textSecondary.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}