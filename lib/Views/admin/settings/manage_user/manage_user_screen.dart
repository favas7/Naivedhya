import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/settings/system_log/system_log_screen.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
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
          'Manage Users',
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
            onPressed: () => context.read<AdminProvider>().refreshUsers(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: colors.textSecondary),
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          // Users List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: colors.primary));
                }

                final filteredUsers = provider.users
                    .where((user) =>
                        user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: colors.textSecondary),
                        const SizedBox(height: 16),
                        Text('No users found', style: TextStyle(color: colors.textSecondary, fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _UserTile(
                      user: user,
                      isDesktop: isDesktop,
                      onToggleAdmin: () => provider.toggleAdminStatus(user.id),
                      onDelete: () => _showDeleteDialog(context, user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UserModel user) {
    final colors = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete, color: colors.error, size: 24),
            const SizedBox(width: 12),
            Text('Delete User', style: TextStyle(color: colors.textPrimary, fontSize: isDesktop ? 20 : 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary, fontSize: isDesktop ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminProvider>().deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error, foregroundColor: AppTheme.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final bool isDesktop;
  final VoidCallback onToggleAdmin;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.isDesktop,
    required this.onToggleAdmin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Card(
      elevation: 1,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: isDesktop ? 30 : 25,
              backgroundColor: colors.primary.withOpacity(0.1),
              child: Text(user.fullName[0].toUpperCase(), style: TextStyle(fontSize: 24, color: colors.primary)),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: TextStyle(fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  Text(user.email, style: TextStyle(fontSize: isDesktop ? 14 : 12, color: colors.textSecondary)),
                  if (user.usertype == 'admin') ...[
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('Admin', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(user.usertype == 'admin' ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined, color: colors.primary),
                  onPressed: onToggleAdmin,
                  tooltip: 'Toggle Admin',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}