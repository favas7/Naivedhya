import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/menu_model.dart';
import 'package:naivedhya/services/menu_service.dart';

class AddEditMenuItemDialog extends StatefulWidget {
  final String restaurantId;
  final MenuItem? menuItem; // null for add, MenuItem for edit
  final List<String> categories;
  final VoidCallback? onSuccess;

  const AddEditMenuItemDialog({
    super.key,
    required this.restaurantId,
    this.menuItem,
    required this.categories,
    this.onSuccess,
  });

  @override
  State<AddEditMenuItemDialog> createState() => _AddEditMenuItemDialogState();
}

class _AddEditMenuItemDialogState extends State<AddEditMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockController = TextEditingController();
  final MenuService _menuService = MenuService();

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = false;

  // Customizations management
  List<MenuItemCustomization> _customizations = [];

  // Predefined categories
  final List<String> _defaultCategories = [
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
      _stockController.text = menuItem.stockQuantity.toString();
      _lowStockController.text = menuItem.lowStockThreshold.toString();
      _selectedCategory = menuItem.category;
      _isAvailable = menuItem.isAvailable;
      _customizations = List.from(menuItem.customizations);
    } else {
      _stockController.text = '0';
      _lowStockController.text = '5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
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
        stockQuantity: int.parse(_stockController.text.trim()),
        lowStockThreshold: int.parse(_lowStockController.text.trim()),
        customizations: _customizations,
      );

      bool success;
      if (_isEditMode) {
        success = await _menuService.updateMenuItem(menuItem);
      } else {
        success = await _menuService.createMenuItem(menuItem);
      }

      if (success) {
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

  void _addCustomization() {
    showDialog(
      context: context,
      builder: (context) => _CustomizationDialog(
        onSave: (customization) {
          setState(() {
            _customizations.add(customization);
          });
        },
      ),
    );
  }

  void _editCustomization(int index) {
    showDialog(
      context: context,
      builder: (context) => _CustomizationDialog(
        customization: _customizations[index],
        onSave: (customization) {
          setState(() {
            _customizations[index] = customization;
          });
        },
      ),
    );
  }

  void _deleteCustomization(int index) {
    setState(() {
      _customizations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description Field
                      _buildLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                          'Enter description (optional)',
                          Icons.description,
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Price and Category Row
                      Row(
                        children: [
                          // Price Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Price (₹) *'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: _buildInputDecoration(
                                    '0.00',
                                    Icons.currency_rupee,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                                  items: (widget.categories.isEmpty 
                                      ? _defaultCategories 
                                      : widget.categories).map((category) {
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
                      
                      // Stock Quantity and Low Stock Threshold Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Stock Quantity'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _stockController,
                                  decoration: _buildInputDecoration(
                                    '0',
                                    Icons.inventory,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter stock quantity';
                                    }
                                    final stock = int.tryParse(value.trim());
                                    if (stock == null || stock < 0) {
                                      return 'Invalid quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Low Stock Alert'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _lowStockController,
                                  decoration: _buildInputDecoration(
                                    '5',
                                    Icons.warning_amber,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter threshold';
                                    }
                                    final threshold = int.tryParse(value.trim());
                                    if (threshold == null || threshold < 0) {
                                      return 'Invalid threshold';
                                    }
                                    return null;
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
                      
                      const SizedBox(height: 24),
                      
                      // Customizations Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Customizations (Optional)'),
                          TextButton.icon(
                            onPressed: _addCustomization,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Customizations List
                      if (_customizations.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No customizations added. Add options like size, toppings, etc.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_customizations.length, (index) {
                          final customization = _customizations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCustomizationIcon(customization.type),
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customization.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${customization.type} • ${customization.options.length} options${customization.isRequired ? " • Required" : ""}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _editCustomization(index),
                                  icon: const Icon(Icons.edit, size: 18),
                                  color: Colors.blue,
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () => _deleteCustomization(index),
                                  icon: const Icon(Icons.delete, size: 18),
                                  color: Colors.red,
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          );
                        }),
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

  IconData _getCustomizationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SIZE':
        return Icons.straighten;
      case 'TOPPING':
        return Icons.add_circle_outline;
      case 'ADDON':
        return Icons.add_box;
      case 'SPICE':
        return Icons.local_fire_department;
      default:
        return Icons.tune;
    }
  }
}

// Customization Dialog
class _CustomizationDialog extends StatefulWidget {
  final MenuItemCustomization? customization;
  final Function(MenuItemCustomization) onSave;

  const _CustomizationDialog({
    this.customization,
    required this.onSave,
  });

  @override
  State<_CustomizationDialog> createState() => _CustomizationDialogState();
}

class _CustomizationDialogState extends State<_CustomizationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _basePriceController = TextEditingController();
  
  String _selectedType = 'ADDON';
  bool _isRequired = false;
  List<CustomizationOption> _options = [];
  
  final List<String> _types = ['SIZE', 'TOPPING', 'ADDON', 'SPICE', 'OTHER'];

  @override
  void initState() {
    super.initState();
    if (widget.customization != null) {
      _nameController.text = widget.customization!.name;
      _basePriceController.text = widget.customization!.basePrice.toString();
      _selectedType = widget.customization!.type;
      _isRequired = widget.customization!.isRequired;
      _options = List.from(widget.customization!.options);
    } else {
      _basePriceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  void _addOption() {
    showDialog(
      context: context,
      builder: (context) => _OptionDialog(
        onSave: (option) {
          setState(() {
            _options.add(option);
          });
        },
      ),
    );
  }

  void _editOption(int index) {
    showDialog(
      context: context,
      builder: (context) => _OptionDialog(
        option: _options[index],
        onSave: (option) {
          setState(() {
            _options[index] = option;
          });
        },
      ),
    );
  }

  void _deleteOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one option'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final customization = MenuItemCustomization(
      customizationId: widget.customization?.customizationId ?? '',
      itemId: widget.customization?.itemId ?? '',
      name: _nameController.text.trim(),
      type: _selectedType,
      basePrice: double.parse(_basePriceController.text.trim()),
      isRequired: _isRequired,
      displayOrder: widget.customization?.displayOrder ?? 0,
      options: _options,
      createdAt: widget.customization?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(customization);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add Customization',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          hintText: 'e.g., Size, Toppings, Spice Level',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: _types.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: TextFormField(
                              controller: _basePriceController,
                              decoration: const InputDecoration(
                                labelText: 'Base Price',
                                prefixText: '₹',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CheckboxListTile(
                        title: const Text('Required Selection'),
                        subtitle: const Text('Customer must choose an option'),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Options *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addOption,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Option'),
                          ),
                        ],
                      ),
                      
                      if (_options.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No options added yet. Add at least one option.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...List.generate(_options.length, (index) {
                          final option = _options[index];
                          return Card(
                            child: ListTile(
                              title: Text(option.name),
                              subtitle: Text('+₹${option.additionalPrice}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _editOption(index),
                                    icon: const Icon(Icons.edit, size: 18),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteOption(index),
                                    icon: const Icon(Icons.delete, size: 18),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
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
}

// Option Dialog
class _OptionDialog extends StatefulWidget {
  final CustomizationOption? option;
  final Function(CustomizationOption) onSave;

  const _OptionDialog({
    this.option,
    required this.onSave,
  });

  @override
  State<_OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<_OptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.option != null) {
      _nameController.text = widget.option!.name;
      _priceController.text = widget.option!.additionalPrice.toString();
    } else {
      _priceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final option = CustomizationOption(
      optionId: widget.option?.optionId ?? '',
      customizationId: widget.option?.customizationId ?? '',
      name: _nameController.text.trim(),
      additionalPrice: double.parse(_priceController.text.trim()),
      displayOrder: widget.option?.displayOrder ?? 0,
      createdAt: widget.option?.createdAt ?? DateTime.now(),
    );

    widget.onSave(option);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.option == null ? 'Add Option' : 'Edit Option'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Option Name *',
                hintText: 'e.g., Small, Medium, Large',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter option name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Additional Price',
                prefixText: '₹',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}