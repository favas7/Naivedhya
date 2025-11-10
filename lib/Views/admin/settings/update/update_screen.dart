import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/settings/system_log/system_log_screen.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart'; // For updates

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
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
          'App Updates',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<AdminProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(Icons.refresh, color: colors.textPrimary),
                onPressed: () => provider.checkForUpdates(),
                tooltip: 'Check for updates',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isCheckingUpdates) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Version
                _buildSectionHeader('Current Version', Icons.info, colors, isDesktop),
                Card(
                  elevation: 1,
                  color: colors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.update, color: colors.primary, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'v${provider.currentVersion ?? '1.0.0'}',
                              style: TextStyle(fontSize: isDesktop ? 20 : 18, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your app is up to date.',
                          style: TextStyle(color: colors.textSecondary, fontSize: isDesktop ? 16 : 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Update History
                _buildSectionHeader('Update History', Icons.history, colors, isDesktop),
                ...provider.updateHistory.map((update) => _UpdateTile(
                      update: update,
                      isDesktop: isDesktop,
                    )),
                if (provider.updateHistory.isEmpty) ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.update, size: 64, color: colors.textSecondary),
                        const SizedBox(height: 16),
                        Text('No update history', style: TextStyle(color: colors.textSecondary, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
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

class _UpdateTile extends StatelessWidget {
  final Map<String, dynamic> update; // Assuming {version, date, changes: [String]}
  final bool isDesktop;

  const _UpdateTile({
    required this.update,
    required this.isDesktop,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(update['version'] ?? 'v1.0.0', style: TextStyle(color: AppTheme.white, fontSize: 12)),
                  backgroundColor: colors.primary,
                ),
                SizedBox(width: 12),
                Text(
                  update['date'] ?? '',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ... (update['changes'] as List? ?? []).map<Widget>((change) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 6, color: colors.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text(change, style: TextStyle(color: colors.textPrimary, fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}