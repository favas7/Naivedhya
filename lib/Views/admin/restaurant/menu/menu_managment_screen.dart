import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/restaurant/menu/widgets/add_menu_item.dart';
import 'package:naivedhya/Views/admin/restaurant/menu/widgets/menu_item_card.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/services/menu_service.dart';

class MenuManagementScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MenuManagementScreen({
    super.key,
    required this.restaurant, required Future<void> Function() onMenuUpdated,
  });

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();
  
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _showAvailableOnly = false;
  String _searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _menuService.getMenuItems(widget.restaurant.id!);
      final categories = await _menuService.getMenuCategories(widget.restaurant.id!);
      
      setState(() {
        _menuItems = items;
        _categories = ['All', ...categories.whereType<String>()];
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading menu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterItems() {
    List<MenuItem> filtered = _menuItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by availability
    if (_showAvailableOnly) {
      filtered = filtered.where((item) => item.isAvailable).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    setState(() {
      _filteredItems = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterItems();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category ?? 'All';
    });
    _filterItems();
  }

  void _onAvailabilityFilterChanged(bool? value) {
    setState(() {
      _showAvailableOnly = value ?? false;
    });
    _filterItems();
  }

  Future<void> _showAddItemDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditMenuItemDialog(
        restaurantId: widget.restaurant.id!,
        categories: _categories.where((c) => c != 'All').toList(),
      ),
    );

    if (result == true) {
      _loadMenuData();
    }
  }

  Future<void> _showEditItemDialog(MenuItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditMenuItemDialog(
        restaurantId: widget.restaurant.id!,
        menuItem: item,
        categories: _categories.where((c) => c != 'All').toList(),
      ),
    );

    if (result == true) {
      _loadMenuData();
    }
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.itemId != null) {
      final success = await _menuService.deleteMenuItem(item.itemId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Menu item deleted successfully' : 'Failed to delete menu item'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          _loadMenuData();
        }
      }
    }
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    if (item.itemId == null) return;

    final success = await _menuService.updateMenuItemAvailability(
      item.itemId!,
      !item.isAvailable,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Item availability updated' 
              : 'Failed to update availability'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        _loadMenuData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.restaurant.name} - Menu'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadMenuData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: _onCategoryChanged,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Available Only Filter
                    Expanded(
                      flex: 3,
                      child: CheckboxListTile(
                        title: const Text(
                          'Available Only',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _showAvailableOnly,
                        onChanged: _onAvailabilityFilterChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _menuItems.isEmpty ? Icons.restaurant_menu : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _menuItems.isEmpty 
                  ? 'No menu items yet'
                  : 'No items match your filters',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _menuItems.isEmpty
                  ? 'Add your first menu item to get started'
                  : 'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (_menuItems.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Menu Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenuData,
      color: AppTheme.primary,
      child: Column(
        children: [
          // Statistics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', _menuItems.length.toString()),
                _buildStatItem('Available', 
                    _menuItems.where((item) => item.isAvailable).length.toString()),
                _buildStatItem('Categories', _categories.length > 1 ? (_categories.length - 1).toString() : '0'),
                _buildStatItem('Showing', _filteredItems.length.toString()),
              ],
            ),
          ),
          
          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return MenuItemCard(
                  menuItem: item,
                  onEdit: () => _showEditItemDialog(item),
                  onDelete: () => _deleteItem(item),
                  onToggleAvailability: () => _toggleAvailability(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}