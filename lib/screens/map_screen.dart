import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final LatLng _currentLocation =
      const LatLng(10.8505, 76.2711); // Kerala center

  // Mock crowdsourced data
  final List<CrowdsourceFlag> _flags = [
    CrowdsourceFlag(
      id: '1',
      location: 'Kochi Metro Station',
      type: FlagType.overcrowding,
      description: 'Very crowded during rush hour',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      reports: 12,
    ),
    CrowdsourceFlag(
      id: '2',
      location: 'NH66 near Aluva',
      type: FlagType.delay,
      description: 'Traffic jam due to road work',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      reports: 8,
    ),
    CrowdsourceFlag(
      id: '3',
      location: 'Thrissur Bus Stand',
      type: FlagType.overcrowding,
      description: 'Long queues for Palakkad buses',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      reports: 6,
    ),
    CrowdsourceFlag(
      id: '4',
      location: 'Ernakulam Junction',
      type: FlagType.delay,
      description: 'Train delayed by 20 minutes',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      reports: 15,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Add markers for crowdsourced flags
  void _addMarkers() {
    _markers.clear();

    // Add markers for each flag
    for (int i = 0; i < _flags.length; i++) {
      final flag = _flags[i];
      final position = _getLocationForFlag(flag);

      _markers.add(
        Marker(
          markerId: MarkerId(flag.id),
          position: position,
          infoWindow: InfoWindow(
            title: flag.location,
            snippet: flag.description,
          ),
          icon: _getMarkerIcon(flag.type),
        ),
      );
    }

    setState(() {});
  }

  // Get location coordinates for a flag
  LatLng _getLocationForFlag(CrowdsourceFlag flag) {
    // Mock coordinates - in real app, these would come from the flag data
    switch (flag.id) {
      case '1':
        return const LatLng(9.9312, 76.2673); // Kochi Metro
      case '2':
        return const LatLng(10.1076, 76.3518); // Aluva
      case '3':
        return const LatLng(10.5276, 76.2144); // Thrissur
      case '4':
        return const LatLng(9.9674, 76.2454); // Ernakulam
      default:
        return _currentLocation;
    }
  }

  // Get marker icon based on flag type
  BitmapDescriptor _getMarkerIcon(FlagType type) {
    switch (type) {
      case FlagType.overcrowding:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case FlagType.delay:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case FlagType.construction:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  // Handle map tap
  void _onMapTapped(LatLng position) {
    // Add a new marker at tapped location
    final newMarker = Marker(
      markerId: MarkerId('tapped_${DateTime.now().millisecondsSinceEpoch}'),
      position: position,
      infoWindow: const InfoWindow(
        title: 'Tapped Location',
        snippet: 'Tap to add a report',
      ),
    );

    setState(() {
      _markers.add(newMarker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps View
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _addMarkers();
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 10.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onTap: (LatLng position) {
              _onMapTapped(position);
            },
          ),

          // Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Where do you want to go?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: _performSearch,
              ),
            ),
          ),

          // Flags overlay in bottom sheet style
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Live Reports',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text('${_flags.length}'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _flags.length,
                        itemBuilder: (context, index) {
                          return FlagCard(flag: _flags[index]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReportDialog(context),
        child: const Icon(Icons.add_location),
      ),
    );
  }

  void _performSearch(String query) {
    // Mock search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for "$query"...'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Overcrowding'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Delays'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Construction'),
              value: false,
              onChanged: (value) {},
            ),
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text(
            'Help the community by reporting transportation issues!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your report! 🙏'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

enum FlagType { overcrowding, delay, construction }

class CrowdsourceFlag {
  final String id;
  final String location;
  final FlagType type;
  final String description;
  final DateTime timestamp;
  final int reports;

  CrowdsourceFlag({
    required this.id,
    required this.location,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.reports,
  });
}

class FlagCard extends StatelessWidget {
  final CrowdsourceFlag flag;

  const FlagCard({super.key, required this.flag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFlagColor(flag.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFlagIcon(flag.type),
                    color: _getFlagColor(flag.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flag.location,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getFlagTypeText(flag.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getFlagColor(flag.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(flag.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${flag.reports}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              flag.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFlagColor(FlagType type) {
    switch (type) {
      case FlagType.overcrowding:
        return Colors.red;
      case FlagType.delay:
        return Colors.orange;
      case FlagType.construction:
        return Colors.blue;
    }
  }

  IconData _getFlagIcon(FlagType type) {
    switch (type) {
      case FlagType.overcrowding:
        return Icons.group;
      case FlagType.delay:
        return Icons.access_time;
      case FlagType.construction:
        return Icons.construction;
    }
  }

  String _getFlagTypeText(FlagType type) {
    switch (type) {
      case FlagType.overcrowding:
        return 'Overcrowding';
      case FlagType.delay:
        return 'Delay';
      case FlagType.construction:
        return 'Construction';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
