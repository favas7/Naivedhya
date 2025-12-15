import 'package:flutter/material.dart';
import 'package:naivedhya/providers/menu_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class AddMenuItemDialog extends StatefulWidget {
  final String hotelId;

  const AddMenuItemDialog({
    super.key,
    required this.hotelId,
  });

  @override
  State<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedAttribute = 'veg'; // ✅ Default to veg for vegetarian restaurant
  bool _isAvailable = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Add Custom Menu Item',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name *',
                          hintText: 'e.g., Paneer Butter Masala',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.restaurant_menu),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of the item',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Price and Category Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Price *',
                                hintText: '0.00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.currency_rupee),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                hintText: 'e.g., Main Course',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.category),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Item Type - ✅ ONLY VEG AND EGG
                      Text(
                        'Item Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildAttributeChip('veg', '🟢 Veg', colors),
                          const SizedBox(width: 8),
                          _buildAttributeChip('egg', '🟡 Egg', colors),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: Naivedhya serves only vegetarian food',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Availability Toggle
                      SwitchListTile(
                        title: Text(
                          'Available for ordering',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          _isAvailable
                              ? 'This item will be visible to customers'
                              : 'This item will be hidden from customers',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        activeColor: AppTheme.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.textSecondary.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeChip(String value, String label, AppThemeColors colors) {
    final isSelected = _selectedAttribute == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAttribute = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.1)
              : colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colors.primary : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final itemData = {
      'hotel_id': widget.hotelId,
      'item_name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'category_name': _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      'item_attribute': _selectedAttribute,
      'is_available': _isAvailable,
      'in_stock': 2,
    };

    final result = await context.read<MenuProvider>().createMenuItem(itemData);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Menu item added successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to add menu item'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}