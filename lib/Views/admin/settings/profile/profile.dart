import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/providers/auth_provider.dart'; // Assuming AuthProvider for user data

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Use _user (UserModel) from AuthProvider, not currentUser
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user; // UserModel?
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textPrimary),
            onPressed: () {
              context.read<AuthProvider>().refreshUser();
            },
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              elevation: 1,
              color: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: isDesktop ? 60 : 50,
                          backgroundColor: colors.primary.withOpacity(0.1),
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // TODO: Use actual user image
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Implement image picker and upload
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: colors.primary,
                              child: Icon(Icons.camera_alt, color: AppTheme.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile Section
            _buildSectionHeader('Edit Profile', Icons.edit, colors, isDesktop),
            Card(
              elevation: 1,
              color: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        context,
                        'Full Name',
                        Icons.person,
                        _nameController,
                        validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        'Email',
                        Icons.email,
                        _emailController,
                        enabled: false, // Email typically not editable
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        'Phone Number',
                        Icons.phone,
                        _phoneController,
                        validator: (value) => value?.length != 10 ? 'Valid phone required' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Stats Section
            _buildSectionHeader('Account Stats', Icons.analytics, colors, isDesktop),
            Card(
              elevation: 1,
              color: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Orders', '150', Icons.shopping_bag, colors),
                    _buildStatCard('Revenue', '₹45,000', Icons.currency_rupee, colors),
                    _buildStatCard('Customers', '89', Icons.people, colors),
                  ],
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 32 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller, {
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final colors = AppTheme.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.textSecondary),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Save to AuthProvider or Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, AppThemeColors colors) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 32),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        Text(label, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, AppThemeColors colors, bool isDesktop) {
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: isDesktop ? 28 : 24),
        SizedBox(width: isDesktop ? 12 : 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}