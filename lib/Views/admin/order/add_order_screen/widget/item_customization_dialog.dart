  // lib/Views/admin/order/add_order_screen/widgets/item_customization_dialog.dart
  import 'package:flutter/material.dart';
  import 'package:naivedhya/models/menu_model.dart';
  import 'package:naivedhya/models/order_item_model.dart';

  class ItemCustomizationDialog {
    static void show({
      required BuildContext context,
      required MenuItem menuItem,
      required int currentQuantity,
      required Function(OrderItem) onAddItem,
    }) {
      showDialog(
        context: context,
        builder: (context) => _ItemCustomizationDialogContent(
          menuItem: menuItem,
          currentQuantity: currentQuantity,
          onAddItem: onAddItem,
        ),
      );
    }
  }

  class _ItemCustomizationDialogContent extends StatefulWidget {
    final MenuItem menuItem;
    final int currentQuantity;
    final Function(OrderItem) onAddItem;

    const _ItemCustomizationDialogContent({
      required this.menuItem,
      required this.currentQuantity,
      required this.onAddItem,
    });

    @override
    State<_ItemCustomizationDialogContent> createState() => _ItemCustomizationDialogContentState();
  }

  class _ItemCustomizationDialogContentState extends State<_ItemCustomizationDialogContent> {
    late int _quantity;
    late Map<String, String?> _selectedCustomizations; // customizationId -> selectedOptionId
    late Map<String, double> _customizationPrices; // customizationId -> additional price

    @override
    void initState() {
      super.initState();
      _quantity = widget.currentQuantity;
      _selectedCustomizations = {};
      _customizationPrices = {};
      
      // Initialize customization selections
      for (var customization in widget.menuItem.customizations) {
        _selectedCustomizations[customization.customizationId] = null;
        _customizationPrices[customization.customizationId] = 0;
      }
    }

    double get _totalAdditionalPrice {
      return _customizationPrices.values.fold(0, (sum, price) => sum + price);
    }

    double get _pricePerItem {
      return widget.menuItem.price + _totalAdditionalPrice;
    }

    double get _totalPrice {
      return _pricePerItem * _quantity;
    }

    bool get _allRequiredCustomizationsSelected {
      return widget.menuItem.customizations.every((customization) {
        if (customization.isRequired) {
          return _selectedCustomizations[customization.customizationId] != null;
        }
        return true;
      });
    }

  void _onAddItem() {
      if (!_allRequiredCustomizationsSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all required customizations')),
        );
        return;
      }

      // Build selected customizations list
      final selectedCustomizations = <SelectedCustomization>[];
      
      for (var customization in widget.menuItem.customizations) {
        final selectedOptionId = _selectedCustomizations[customization.customizationId];
        if (selectedOptionId != null) {
          final selectedOption = customization.options.firstWhere(
            (o) => o.optionId == selectedOptionId,
          );
          
          selectedCustomizations.add(
            SelectedCustomization(
              customizationId: customization.customizationId,
              customizationName: customization.name,
              customizationType: customization.type,
              selectedOptionId: selectedOption.optionId,
              selectedOptionName: selectedOption.name,
              additionalPrice: selectedOption.additionalPrice,
            ),
          );
        }
      }

      // Create OrderItem - FIXED: assign to variable and include selectedCustomizations
      final orderItem = OrderItem(
        orderId: 'some_id',
        itemName: widget.menuItem.name,
        quantity: 1,
        price: widget.menuItem.price,
        selectedCustomizations: selectedCustomizations,
        customizationAdditionalPrice: selectedCustomizations
            .fold(0.0, (sum, c) => sum + c.additionalPrice), 
            itemId: '',
      );

      widget.onAddItem(orderItem);
      Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
      final isMobile = MediaQuery.of(context).size.width < 600;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: isMobile ? double.infinity : 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.menuItem.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (widget.menuItem.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.menuItem.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customizations Section
                      if (widget.menuItem.customizations.isNotEmpty) ...[
                        const Text(
                          'Customizations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...widget.menuItem.customizations.map((customization) {
                          return _buildCustomizationSection(customization);
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Quantity Section
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Price Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPriceRow(
                              'Base Price',
                              '₹${widget.menuItem.price.toStringAsFixed(2)}',
                            ),
                            if (_totalAdditionalPrice > 0) ...[
                              const Divider(height: 12),
                              _buildPriceRow(
                                'Customizations',
                                '₹${_totalAdditionalPrice.toStringAsFixed(2)}',
                                isSubtotal: true,
                              ),
                            ],
                            const Divider(height: 16),
                            _buildPriceRow(
                              'Price per Item',
                              '₹${_pricePerItem.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildPriceRow(
                              'Total × $_quantity',
                              '₹${_totalPrice.toStringAsFixed(2)}',
                              isBold: true,
                              isLarge: true,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
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
                        onPressed: _allRequiredCustomizationsSelected ? _onAddItem : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add to Order'),
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

    Widget _buildCustomizationSection(MenuItemCustomization customization) {
      final isRequired = customization.isRequired;
      final selectedOptionId = _selectedCustomizations[customization.customizationId];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                customization.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...customization.options.map((option) {
            return _buildCustomizationOption(customization, option, selectedOptionId);
          }),
          const SizedBox(height: 16),
        ],
      );
    }

    Widget _buildCustomizationOption(
      MenuItemCustomization customization,
      CustomizationOption option,
      String? selectedOptionId,
    ) {
      final isSelected = selectedOptionId == option.optionId;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCustomizations[customization.customizationId] = option.optionId;
              _customizationPrices[customization.customizationId] = option.additionalPrice;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.additionalPrice > 0)
                      Text(
                        '+₹${option.additionalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Radio<String>(
                      value: option.optionId,
                      groupValue: selectedOptionId,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCustomizations[customization.customizationId] = value;
                            _customizationPrices[customization.customizationId] = option.additionalPrice;
                          });
                        }
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildPriceRow(
      String label,
      String value, {
      bool isBold = false,
      bool isSubtotal = false,
      bool isLarge = false,
      Color? color,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      );
    }
  }