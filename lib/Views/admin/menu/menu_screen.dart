import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/menu/widgets/add_menu_item_dialog.dart';
import 'package:naivedhya/Views/admin/menu/widgets/menu_sync_status.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/providers/menu_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  final String hotelId;

  const MenuScreen({
    super.key,
    required this.hotelId,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().initialize(widget.hotelId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(colors),
          _buildStatsBar(colors),
          _buildFiltersBar(colors),
          Expanded(
            child: _buildMenuTable(colors),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your restaurant menu items',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Sync Status
          MenuSyncStatus(hotelId: widget.hotelId),
          const SizedBox(width: 16),
          // Sync Button
          Consumer<MenuProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isSyncing
                    ? null
                    : () => _syncMenu(context),
                icon: provider.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(provider.isSyncing ? 'Syncing...' : 'Sync Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(AppThemeColors colors) {
    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        return Container(
          padding: const EdgeInsets.all(16),
          color: colors.surface,
          child: Row(
            children: [
              _buildStatCard(
                colors,
                'Total Items',
                stats['total']?.toString() ?? '0',
                Icons.restaurant_menu,
                AppTheme.primary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                colors,
                'Available',
                stats['available']?.toString() ?? '0',
                Icons.check_circle_outline,
                AppTheme.success,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                colors,
                'Unavailable',
                stats['unavailable']?.toString() ?? '0',
                Icons.block,
                AppTheme.error,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                colors,
                'From Petpooja',
                stats['fromPetpooja']?.toString() ?? '0',
                Icons.cloud_sync,
                AppTheme.info,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                colors,
                'Custom',
                stats['custom']?.toString() ?? '0',
                Icons.edit,
                AppTheme.warning,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    AppThemeColors colors,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.textSecondary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
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

  Widget _buildFiltersBar(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MenuProvider>().setSearchQuery(null);
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                context.read<MenuProvider>().setSearchQuery(value.isEmpty ? null : value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Category Filter
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, provider, child) {
                final categories = provider.categoryNames;

                return DropdownButtonFormField<String>(
                  value: provider.selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    provider.setSelectedCategory(value);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Clear Filters Button
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              context.read<MenuProvider>().clearFilters();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTable(AppThemeColors colors) {
    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading menu items...',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.refresh(widget.hotelId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.menuItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: colors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No menu items found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sync menu from Petpooja or add custom items',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _syncMenu(context),
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync from Petpooja'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Custom Item'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.textSecondary.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildTableHeader(colors),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildTableRow(
                        colors,
                        provider.menuItems[index],
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('', 50), // Icon
          _buildHeaderCell('Item Name', 250),
          _buildHeaderCell('Category', 150),
          _buildHeaderCell('Price', 100),
          _buildHeaderCell('Type', 80),
          _buildHeaderCell('Status', 120),
          _buildHeaderCell('Stock', 100),
          _buildHeaderCell('Source', 120),
          _buildHeaderCell('Actions', 150),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    final colors = AppTheme.of(context);
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTableRow(AppThemeColors colors, MenuItem item, int index) {
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? colors.surface : colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.textSecondary.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          SizedBox(
            width: 50,
            child: Text(
              item.attributeIcon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          // Item Name
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Category
          SizedBox(
            width: 150,
            child: Text(
              item.categoryName ?? 'Uncategorized',
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ),
          // Price
          SizedBox(
            width: 100,
            child: Text(
              '₹${item.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          // Type (Veg/Non-veg/Egg)
          SizedBox(
            width: 80,
            child: Text(
              item.itemAttribute ?? 'N/A',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ),
          // Status
          SizedBox(
            width: 120,
            child: _buildStatusToggle(item),
          ),
          // Stock Status
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isInStock
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: item.isInStock ? AppTheme.success : AppTheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Source
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(
                  item.isFromPetpooja ? Icons.cloud_done : Icons.edit,
                  size: 16,
                  color: item.isFromPetpooja ? AppTheme.info : AppTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  item.isFromPetpooja ? 'Petpooja' : 'Custom',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          SizedBox(
            width: 150,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: AppTheme.info),
                  onPressed: () => _showEditItemDialog(context, item),
                  tooltip: 'Edit',
                ),
                if (!item.isFromPetpooja)
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: AppTheme.error),
                    onPressed: () => _showDeleteDialog(context, item),
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(MenuItem item) {
    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        return Switch(
          value: item.isAvailable,
          onChanged: (value) {
            provider.toggleItemAvailability(item.itemId, value);
          },
          activeColor: AppTheme.success,
        );
      },
    );
  }

  Future<void> _syncMenu(BuildContext context) async {
    final provider = context.read<MenuProvider>();

    final result = await provider.syncMenuFromPetpooja(widget.hotelId);

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✅ Menu synced successfully!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${provider.stats['total']} items updated',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Menu sync failed: ${provider.error}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMenuItemDialog(hotelId: widget.hotelId),
    );
  }

  void _showEditItemDialog(BuildContext context, MenuItem item) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _showDeleteDialog(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<MenuProvider>()
                  .deleteMenuItem(item.itemId);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Item deleted successfully'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Failed to delete item'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}