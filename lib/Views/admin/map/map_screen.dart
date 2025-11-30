import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naivedhya/services/delivery_person_service.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'dart:async';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // State variables
  String selectedFilter = 'All';
  bool showDeliveryStaff = true;
  bool showCustomers = true;
  bool showRestaurants = true;

  // Map variables
  GoogleMapController? _mapController;
  final DeliveryPersonnelService _personnelService = DeliveryPersonnelService();
  List<DeliveryPersonnel> _allPersonnel = [];
  List<DeliveryPersonnel> _filteredPersonnel = [];
  Set<Marker> _markers = {};
  RealtimeChannel? _realtimeChannel;
  Timer? _refreshTimer;

  // Kochi, South Railway Station coordinates
  static const LatLng _initialCenter = LatLng(9.9816, 76.2999);

  // Marker icons
  BitmapDescriptor? _activeIcon;
  BitmapDescriptor? _deliveringIcon;
  BitmapDescriptor? _inactiveIcon;

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    await _loadCustomMarkers();
    await _loadDeliveryPersonnel();
    _setupRealtimeSubscription();
    _setupPeriodicRefresh();
    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomMarkers() async {
    _activeIcon = await _createCustomMarker(Colors.green, Icons.delivery_dining);
    _deliveringIcon = await _createCustomMarker(Colors.orange, Icons.two_wheeler);
    _inactiveIcon = await _createCustomMarker(Colors.grey, Icons.person_off);
  }

  Future<BitmapDescriptor> _createCustomMarker(Color color, IconData icon) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = 100.0;

    // Draw circle background
    final paint = Paint()..color = color;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

    // Draw icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 50,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _loadDeliveryPersonnel() async {
    try {
      final personnel = await _personnelService.fetchDeliveryPersonnelWithLocation();
      if (mounted) {
        setState(() {
          _allPersonnel = personnel;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load delivery personnel: $e');
      }
    }
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = _personnelService.subscribeToLocationUpdates(
      (newPerson) {
        // Handle insert
        if (mounted) {
          setState(() {
            if (!_allPersonnel.any((p) => p.userId == newPerson.userId)) {
              _allPersonnel.add(newPerson);
            }
            _applyFilters();
          });
        }
      },
      (updatedPerson) {
        // Handle update
        if (mounted) {
          setState(() {
            final index = _allPersonnel.indexWhere((p) => p.userId == updatedPerson.userId);
            if (index != -1) {
              _allPersonnel[index] = updatedPerson;
            } else {
              _allPersonnel.add(updatedPerson);
            }
            _applyFilters();
          });
        }
      },
      (userId) {
        // Handle delete
        if (mounted) {
          setState(() {
            _allPersonnel.removeWhere((p) => p.userId == userId);
            _applyFilters();
          });
        }
      },
    );
  }

  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadDeliveryPersonnel();
      }
    });
  }

  void _applyFilters() {
    _filteredPersonnel = _allPersonnel.where((person) {
      // Apply status filter
      if (!person.matchesFilter(selectedFilter)) return false;

      // Apply toggle filters
      if (!showDeliveryStaff) return false;

      return true;
    }).toList();

    _updateMarkers();
  }

  void _updateMarkers() {
    if (_activeIcon == null || _deliveringIcon == null || _inactiveIcon == null) {
      return;
    }

    final markers = _filteredPersonnel
        .where((person) => person.hasLocation)
        .map((person) {
      BitmapDescriptor icon;
      if (!person.isAvailable) {
        icon = _inactiveIcon!;
      } else if (person.assignedOrders.isNotEmpty) {
        icon = _deliveringIcon!;
      } else {
        icon = _activeIcon!;
      }

      return Marker(
        markerId: MarkerId(person.userId),
        position: LatLng(person.latitude!, person.longitude!),
        icon: icon,
        onTap: () => _showPersonnelDetails(person),
      );
    }).toSet();

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _showPersonnelDetails(DeliveryPersonnel person) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(person.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', person.status, theme),
            _detailRow('Phone', person.phone, theme),
            _detailRow('Email', person.email, theme),
            _detailRow('Vehicle', person.vehicleInfo, theme),
            _detailRow('Active Orders', person.activeOrdersCount.toString(), theme),
            _detailRow('Rating', '${person.rating.toStringAsFixed(1)} ⭐', theme),
            _detailRow('Total Deliveries', person.totalDeliveries.toString(), theme),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _centerMapOnPersonnel() {
    if (_filteredPersonnel.isEmpty || _mapController == null) return;

    final validPersonnel = _filteredPersonnel.where((p) => p.hasLocation).toList();
    if (validPersonnel.isEmpty) return;

    if (validPersonnel.length == 1) {
      final person = validPersonnel.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(person.latitude!, person.longitude!),
          14,
        ),
      );
    } else {
      double minLat = validPersonnel.first.latitude!;
      double maxLat = validPersonnel.first.latitude!;
      double minLng = validPersonnel.first.longitude!;
      double maxLng = validPersonnel.first.longitude!;

      for (var person in validPersonnel) {
        if (person.latitude! < minLat) minLat = person.latitude!;
        if (person.latitude! > maxLat) maxLat = person.latitude!;
        if (person.longitude! < minLng) minLng = person.longitude!;
        if (person.longitude! > maxLng) maxLng = person.longitude!;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50,
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _refreshTimer?.cancel();
    if (_realtimeChannel != null) {
      _personnelService.unsubscribeFromLocationUpdates(_realtimeChannel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 480 && screenWidth <= 768;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Location Tracking',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Real-time tracking of delivery staff, customers, and Restaurants',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: theme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Controls and Map Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Control Panel
              if (isDesktop)
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: _buildControlPanel(theme),
                ),

              // Map Container
              Expanded(
                child: _buildMapContainer(theme, isDesktop, isTablet),
              ),
            ],
          ),

          // Mobile Control Panel
          if (!isDesktop) ...[
            const SizedBox(height: 20),
            _buildControlPanel(theme),
          ],

          const SizedBox(height: 20),

          // Statistics Cards
          _buildStatisticsCards(theme, isDesktop, isTablet),

          const SizedBox(height: 20),

          // Recent Activity
          _buildRecentActivity(theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildControlPanel(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Map Controls',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Filter Dropdown
          DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'Delivering', child: Text('Delivering')),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 20),

          // Toggle Switches
          Text(
            'Show on Map',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text('Delivery Staff'),
            subtitle: Text(
              'Active delivery personnel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showDeliveryStaff,
            onChanged: (value) {
              setState(() {
                showDeliveryStaff = value;
                _applyFilters();
              });
            },
            activeColor: theme.primary,
          ),

          SwitchListTile(
            title: const Text('Customers'),
            subtitle: Text(
              'Customer locations (Coming soon)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showCustomers,
            onChanged: null,
            activeColor: theme.primary,
          ),

          SwitchListTile(
            title: const Text('Restaurants'),
            subtitle: Text(
              'Partner Restaurants (Coming soon)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: showRestaurants,
            onChanged: null,
            activeColor: theme.primary,
          ),

          const SizedBox(height: 20),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadDeliveryPersonnel,
              icon: _isLoading 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.surface,
                    ),
                  )
                : const Icon(Icons.refresh),
              label: Text(_isLoading ? 'Refreshing...' : 'Refresh Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _filteredPersonnel.isEmpty ? null : _centerMapOnPersonnel,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Center on Staff'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer(AppThemeColors theme, bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 500 : 400,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialCenter,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_filteredPersonnel.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _centerMapOnPersonnel();
                  });
                }
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              compassEnabled: true,
              mapType: MapType.normal,
            ),

            // Map Legend
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legend',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.green, 'Active'),
                    _buildLegendItem(Colors.orange, 'Delivering'),
                    _buildLegendItem(Colors.grey, 'Inactive'),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                color: theme.surface.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Loading delivery personnel...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: theme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

            // No data indicator
            if (!_isLoading && _filteredPersonnel.isEmpty)
              Container(
                color: theme.surface.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No delivery personnel with location data',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: theme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(AppThemeColors theme, bool isDesktop, bool isTablet) {
    final activeCount = _allPersonnel.where((p) => p.isAvailable && p.assignedOrders.isEmpty).length;
    final deliveringCount = _allPersonnel.where((p) => p.assignedOrders.isNotEmpty).length;
    final inactiveCount = _allPersonnel.where((p) => !p.isAvailable).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 2 : 3),
      children: [
        _buildStatCard(theme, 'Active Staff', activeCount.toString(), Icons.delivery_dining, theme.success),
        _buildStatCard(theme, 'Delivering', deliveringCount.toString(), Icons.two_wheeler, theme.warning),
        _buildStatCard(theme, 'Inactive', inactiveCount.toString(), Icons.person_off, theme.textSecondary),
        _buildStatCard(theme, 'Total Staff', _allPersonnel.length.toString(), Icons.people, theme.info),
      ],
    );
  }

  Widget _buildStatCard(AppThemeColors theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: color,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AppThemeColors theme, bool isDesktop) {
    final recentActivity = _allPersonnel.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (recentActivity.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.textSecondary,
                      ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivity.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.textSecondary.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final person = recentActivity[index];
                final minutesAgo = DateTime.now().difference(person.updatedAt).inMinutes;

                Color statusColor;
                if (!person.isAvailable) {
                  statusColor = theme.textSecondary;
                } else if (person.assignedOrders.isNotEmpty) {
                  statusColor = theme.warning;
                } else {
                  statusColor = theme.success;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(Icons.location_on, color: statusColor),
                  ),
                  title: Text(
                    '${person.displayName} location updated',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    minutesAgo == 0 ? 'Just now' : '$minutesAgo minute${minutesAgo == 1 ? '' : 's'} ago',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      person.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}