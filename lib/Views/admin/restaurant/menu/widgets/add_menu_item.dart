import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/services/menu_service.dart';

class AddEditMenuItemDialog extends StatefulWidget {
  final String restaurantId;
  final MenuItem? menuItem; // null for add, MenuItem for edit
  final VoidCallback? onSuccess;

  const AddEditMenuItemDialog({
    super.key,
    required this.restaurantId,
    this.menuItem,
    this.onSuccess, required List<String> categories,
  });

  @override
  State<AddEditMenuItemDialog> createState() => _AddEditMenuItemDialogState();
}

class _AddEditMenuItemDialogState extends State<AddEditMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final MenuService _menuService = MenuService();

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = false;

  // Predefined categories
  final List<String> _categories = [
    'Appetizers',
    'Main Course',
    'Beverages',
    'Desserts',
    'Snacks',
    'Soups',
    'Salads',
    'Sides',
    'Specials',
    'Other',
  ];

  bool get _isEditMode => widget.menuItem != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditMode) {
      final menuItem = widget.menuItem!;
      _nameController.text = menuItem.name;
      _descriptionController.text = menuItem.description ?? '';
      _priceController.text = menuItem.price.toString();
      _selectedCategory = menuItem.category;
      _isAvailable = menuItem.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final menuItem = MenuItem(
        itemId: _isEditMode ? widget.menuItem!.itemId : null,
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        isAvailable: _isAvailable,
        category: _selectedCategory,
      );

      MenuItem? result;
      if (_isEditMode) {
        result = await _menuService.updateMenuItem(
          widget.menuItem!.itemId!,
          menuItem,
        );
      } else {
        result = await _menuService.createMenuItem(menuItem);
      }

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode 
                    ? 'Menu item updated successfully' 
                    : 'Menu item added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSuccess?.call();
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode 
                    ? 'Failed to update menu item' 
                    : 'Failed to add menu item',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditMode ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditMode ? 'Edit Menu Item' : 'Add Menu Item',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildLabel('Item Name *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration(
                          'Enter item name',
                          Icons.restaurant_menu,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter item name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description Field
                      _buildLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                          'Enter item description (optional)',
                          Icons.description,
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price and Category Row
                      Row(
                        children: [
                          // Price Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Price *'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: _buildInputDecoration(
                                    '0.00',
                                    Icons.currency_rupee,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter price';
                                    }
                                    final price = double.tryParse(value.trim());
                                    if (price == null) {
                                      return 'Invalid price format';
                                    }
                                    if (price <= 0) {
                                      return 'Price must be greater than 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Category Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Category'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: _buildInputDecoration(
                                    'Select category',
                                    Icons.category,
                                  ),
                                  items: _categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Availability Switch
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isAvailable ? Icons.check_circle : Icons.cancel,
                              color: _isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item Availability',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isAvailable 
                                        ? 'This item is available for ordering'
                                        : 'This item is currently unavailable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  _isAvailable = value;
                                });
                              },
                              activeColor: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMenuItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Update Item' : 'Add Item',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}