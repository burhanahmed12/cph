import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

class MapLocationPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String initialAddress;
  final Function(double lat, double lng, String address) onLocationSelected;

  const MapLocationPicker({
    super.key,
    this.initialLat = 37.7749,
    this.initialLng = -122.4194,
    this.initialAddress = '742 Market Street, San Francisco, CA',
    required this.onLocationSelected,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  late LatLng _selectedPosition;
  late String _currentAddress;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _quickLocations = [
    {'name': 'Market Street', 'lat': 37.7749, 'lng': -122.4194, 'address': '742 Market St, San Francisco, CA'},
    {'name': 'Mission District', 'lat': 37.7599, 'lng': -122.4148, 'address': '2480 Mission St, San Francisco, CA'},
    {'name': 'Financial Dist', 'lat': 37.7946, 'lng': -122.4010, 'address': '100 Pine St, San Francisco, CA'},
    {'name': 'SOMA Office', 'lat': 37.7785, 'lng': -122.3956, 'address': '500 Howard St, San Francisco, CA'},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPosition = LatLng(widget.initialLat, widget.initialLng);
    _currentAddress = widget.initialAddress;
    _searchController.text = _currentAddress;
  }

  void _updatePosition(LatLng newPos, String address) {
    setState(() {
      _selectedPosition = newPos;
      _currentAddress = address;
      _searchController.text = address;
    });
    _mapController.move(newPos, 15.0);
    widget.onLocationSelected(newPos.latitude, newPos.longitude, address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Map Layer
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPosition,
                initialZoom: 14.5,
                onTap: (tapPosition, point) {
                  final mockAdd = 'Pin Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
                  _updatePosition(point, mockAdd);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fixnear.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Address Bar
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Quick Preset Buttons
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickLocations.map((loc) {
                    final LatLng pos = LatLng(loc['lat'], loc['lng']);
                    final bool isSel = (_selectedPosition.latitude - pos.latitude).abs() < 0.001;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: isSel ? Colors.white : AppColors.primary,
                        ),
                        label: Text(
                          loc['name'],
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isSel ? AppColors.primary : Colors.white,
                        elevation: 3,
                        side: BorderSide.none,
                        onPressed: () => _updatePosition(pos, loc['address']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
