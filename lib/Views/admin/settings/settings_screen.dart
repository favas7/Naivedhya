import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/settings/profile/profile.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/providers/theme_provider.dart'; // Adjust path as needed

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR';

  final List<String> _languages = ['English', 'Hindi', 'Malayalam'];
  final List<String> _currencies = ['INR', 'USD', 'EUR'];

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
          'Settings',
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
              // TODO: Implement refresh logic if needed (e.g., reload settings from provider)
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
            // General Settings Section
            _buildSectionHeader('General', Icons.settings, colors, isDesktop),
            _buildSectionCard(
              context,
              colors,
              isDesktop,
              children: [
                _buildDropdownSetting(
                  context,
                  'Language',
                  Icons.language,
                  _selectedLanguage,
                  _languages,
                  (String? value) {
                    setState(() {
                      _selectedLanguage = value ?? _selectedLanguage;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownSetting(
                  context,
                  'Currency',
                  Icons.currency_exchange,
                  _selectedCurrency,
                  _currencies,
                  (String? value) {
                    setState(() {
                      _selectedCurrency = value ?? _selectedCurrency;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader('Appearance', Icons.color_lens, colors, isDesktop),
            _buildSectionCard(
              context,
              colors,
              isDesktop,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, provider, child) {
                    return _buildToggleSetting(
                      context,
                      'Dark Mode',
                      Icons.brightness_2,
                      provider.isDarkMode,
                      (bool value) {
                        if (value) {
                          provider.setDarkMode();
                        } else {
                          provider.setLightMode();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications, colors, isDesktop),
            _buildSectionCard(
              context,
              colors,
              isDesktop,
              children: [
                _buildToggleSetting(
                  context,
                  'Push Notifications',
                  Icons.notifications_active,
                  _pushNotifications,
                  (bool value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    // TODO: Save to provider or API
                  },
                ),
                const SizedBox(height: 16),
                _buildToggleSetting(
                  context,
                  'Email Notifications',
                  Icons.email,
                  _emailNotifications,
                  (bool value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                    // TODO: Save to provider or API
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account & Security Section
            _buildSectionHeader('Account & Security', Icons.security, colors, isDesktop),
            _buildSectionCard(
              context,
              colors,
              isDesktop,
              children: [
                _buildNavigationSetting(
                  context,
                  'Profile',
                  Icons.person,
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationSetting(
                  context,
                  'Change Password',
                  Icons.lock,
                  () {
                    // TODO: Show password change dialog or navigate
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationSetting(
                  context,
                  'Logout',
                  Icons.logout,
                  () {
                    // TODO: Confirm and logout
                    _showLogoutDialog(context, colors, isDesktop);
                  },
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Admin-Specific Section
            _buildSectionHeader('Admin Controls', Icons.admin_panel_settings, colors, isDesktop),
            _buildSectionCard(
              context,
              colors,
              isDesktop,
              children: [
                _buildNavigationSetting(
                  context,
                  'Manage Users',
                  Icons.people,
                  () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUsersScreen()));
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationSetting(
                  context,
                  'System Logs',
                  Icons.history,
                  () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => SystemLogsScreen()));
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationSetting(
                  context,
                  'App Updates',
                  Icons.system_update,
                  () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatesScreen()));
                  },
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 32 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    AppThemeColors colors,
    bool isDesktop,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: colors.primary,
          size: isDesktop ? 28 : 24,
        ),
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

  Widget _buildSectionCard(
    BuildContext context,
    AppThemeColors colors,
    bool isDesktop, {
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final colors = AppTheme.of(context);
    return Row(
      children: [
        Icon(icon, color: colors.textSecondary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context,
    String title,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final colors = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colors.textSecondary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: TextStyle(color: colors.textPrimary)),
            );
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildNavigationSetting(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final colors = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? colors.error : colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDestructive ? colors.error : colors.textPrimary,
                      fontSize: 16,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppThemeColors colors, bool isDesktop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: colors.error, size: 24),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: isDesktop ? 20 : 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}