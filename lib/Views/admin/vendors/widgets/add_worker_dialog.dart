// lib/Views/admin/vendors/widgets/add_worker_dialog.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/worker_model.dart';
import 'package:naivedhya/services/worker_service.dart';
import 'package:naivedhya/utils/color_theme.dart';

class AddWorkerDialog extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final Worker? worker; // If provided, it's edit mode

  const AddWorkerDialog({
    super.key,
    required this.vendorId,
    required this.vendorName,
    this.worker,
  });

  @override
  State<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<AddWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final WorkerService _workerService = WorkerService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _photoUrlController;
  late TextEditingController _roleController;
  late TextEditingController _workingHoursController;
  late TextEditingController _addressController;

  String _selectedEmploymentStatus = 'Active';
  String _selectedShiftType = 'Morning';
  String? _selectedIdProofType;

  bool _isLoading = false;

  final List<String> _employmentStatuses = ['Active', 'Inactive', 'On Leave'];
  final List<String> _shiftTypes = ['Morning', 'Evening', 'Night', 'Rotating'];
  final List<String> _idProofTypes = [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Voter ID',
    'Passport',
    'Other',
  ];

  final List<String> _commonRoles = [
    'Chef',
    'Sous Chef',
    'Cook',
    'Waiter',
    'Server',
    'Bartender',
    'Cashier',
    'Manager',
    'Supervisor',
    'Receptionist',
    'Cleaner',
    'Dishwasher',
    'Kitchen Helper',
    'Delivery Boy',
    'Driver',
    'Security Guard',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing worker data or empty
    _nameController = TextEditingController(text: widget.worker?.name ?? '');
    _phoneController = TextEditingController(text: widget.worker?.phone ?? '');
    _emailController = TextEditingController(text: widget.worker?.email ?? '');
    _photoUrlController =
        TextEditingController(text: widget.worker?.photoUrl ?? '');
    _roleController = TextEditingController(text: widget.worker?.role ?? '');
    _workingHoursController =
        TextEditingController(text: widget.worker?.workingHours ?? '');
    _addressController =
        TextEditingController(text: widget.worker?.address ?? '');

    if (widget.worker != null) {
      _selectedEmploymentStatus = widget.worker!.employmentStatus;
      _selectedShiftType = widget.worker!.shiftType;
      _selectedIdProofType = widget.worker!.idProofType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    _roleController.dispose();
    _workingHoursController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveWorker() async {
    print('🔷 [ADD WORKER] _saveWorker() called');
    print('🔷 [ADD WORKER] Edit Mode: ${widget.worker != null}');
    print('🔷 [ADD WORKER] Vendor ID: ${widget.vendorId}');
    print('🔷 [ADD WORKER] Vendor Name: ${widget.vendorName}');

    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('❌ [ADD WORKER] Form validation failed!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('✅ [ADD WORKER] Form validation passed');

    setState(() => _isLoading = true);

    try {
      // Debug print all field values
      print('📝 [ADD WORKER] Form Data:');
      print('  - Name: ${_nameController.text.trim()}');
      print('  - Phone: ${_phoneController.text.trim()}');
      print('  - Email: ${_emailController.text.trim()}');
      print('  - Role: ${_roleController.text.trim()}');
      print('  - Employment Status: $_selectedEmploymentStatus');
      print('  - Shift Type: $_selectedShiftType');
      print('  - ID Proof Type: $_selectedIdProofType');
      print('  - Working Hours: ${_workingHoursController.text.trim()}');
      print('  - Address: ${_addressController.text.trim()}');

      // Validate role is not empty
      if (_roleController.text.trim().isEmpty) {
        throw Exception('Role cannot be empty');
      }

      // Create worker object
      print('🏗️ [ADD WORKER] Creating Worker object...');
      final worker = Worker(
        id: widget.worker?.id,
        vendorId: widget.vendorId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        role: _roleController.text.trim(),
        employmentStatus: _selectedEmploymentStatus,
        idProofType: _selectedIdProofType,
        shiftType: _selectedShiftType,
        workingHours: _workingHoursController.text.trim().isEmpty
            ? null
            : _workingHoursController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        isActive: _selectedEmploymentStatus != 'Inactive',
      );

      print('✅ [ADD WORKER] Worker object created successfully');
      print('📤 [ADD WORKER] Worker JSON: ${worker.toJson()}');

      // Save to database
      if (widget.worker == null) {
        print('➕ [ADD WORKER] Calling createWorker...');
        final result = await _workerService.createWorker(worker);
        print('✅ [ADD WORKER] Worker created successfully!');
        print('📥 [ADD WORKER] Created worker ID: ${result.id}');
      } else {
        print('✏️ [ADD WORKER] Calling updateWorker...');
        final result = await _workerService.updateWorker(worker);
        print('✅ [ADD WORKER] Worker updated successfully!');
        print('📥 [ADD WORKER] Updated worker ID: ${result.id}');
      }

      if (mounted) {
        print('🎉 [ADD WORKER] Success! Closing dialog...');
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.worker == null
                  ? '✅ Worker added successfully'
                  : '✅ Worker updated successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [ADD WORKER] ERROR occurred!');
      print('❌ [ADD WORKER] Error: $e');
      print('❌ [ADD WORKER] Stack trace: $stackTrace');
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        // Parse error message for user-friendly display
        String errorMessage = 'Error: $e';
        
        if (e.toString().contains('duplicate key')) {
          errorMessage = 'This worker already exists';
        } else if (e.toString().contains('foreign key')) {
          errorMessage = 'Invalid vendor ID. Please refresh and try again.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check your access rights.';
        }
        
        print('❌ [ADD WORKER] User-friendly error: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Technical: ${e.toString()}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy Error',
              textColor: Colors.white,
              onPressed: () {
                // Copy error to clipboard (optional)
                print('📋 [ADD WORKER] Error copied to logs');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final isEditMode = widget.worker != null;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode ? 'Edit Worker' : 'Add New Worker',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vendor: ${widget.vendorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionTitle(colors, 'Basic Information'),
                      const SizedBox(height: 16),

                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name *',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter worker name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone & Email
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number *',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 10) {
                                  return 'Invalid phone';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email (Optional)',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Role & Photo URL
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Role *',
                              icon: Icons.work_outline,
                              value: _roleController.text.isEmpty
                                  ? null
                                  : _roleController.text,
                              items: _commonRoles,
                              onChanged: (value) {
                                setState(() => _roleController.text = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _photoUrlController,
                              label: 'Photo URL (Optional)',
                              icon: Icons.image_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Employment Details Section
                      _buildSectionTitle(colors, 'Employment Details'),
                      const SizedBox(height: 16),

                      // Employment Status & Shift Type
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Employment Status *',
                              icon: Icons.work_outline,
                              value: _selectedEmploymentStatus,
                              items: _employmentStatuses,
                              onChanged: (value) {
                                setState(
                                    () => _selectedEmploymentStatus = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Shift Type *',
                              icon: Icons.schedule,
                              value: _selectedShiftType,
                              items: _shiftTypes,
                              onChanged: (value) {
                                setState(() => _selectedShiftType = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Working Hours & ID Proof
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _workingHoursController,
                              label: 'Working Hours (Optional)',
                              icon: Icons.access_time,
                              hintText: 'e.g., 9 AM - 5 PM',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'ID Proof Type (Optional)',
                              icon: Icons.badge_outlined,
                              value: _selectedIdProofType,
                              items: _idProofTypes,
                              onChanged: (value) {
                                setState(() => _selectedIdProofType = value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Additional Information Section
                      _buildSectionTitle(colors, 'Additional Information'),
                      const SizedBox(height: 16),

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address (Optional)',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.textSecondary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveWorker,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(isEditMode ? Icons.save : Icons.add),
                    label: Text(
                      _isLoading
                          ? 'Saving...'
                          : isEditMode
                              ? 'Update Worker'
                              : 'Add Worker',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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

  Widget _buildSectionTitle(AppThemeColors colors, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final colors = AppTheme.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: colors.primary, size: 20),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final colors = AppTheme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary, size: 20),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}