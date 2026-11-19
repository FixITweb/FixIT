import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/location_helper.dart';

class ServiceLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const ServiceLocationPickerScreen({super.key, this.initialLocation});

  @override
  State<ServiceLocationPickerScreen> createState() =>
      _ServiceLocationPickerScreenState();
}

class _ServiceLocationPickerScreenState
    extends State<ServiceLocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await LocationHelper.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selectedLocation = location);
      _mapController.move(location, 15);
    } on LocationAccessException catch (error) {
      if (!mounted) return;
      _showLocationError(error.message, locationError: error);
    } on Exception catch (error) {
      if (!mounted) return;
      _showLocationError('Could not get your location: $error');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final ethiopiaQuery =
        query.toLowerCase().contains('ethiopia') ? query : '$query, Ethiopia';

    try {
      final matches = await locationFromAddress(ethiopiaQuery);
      if (matches.isEmpty) {
        throw Exception('No matching place was found.');
      }
      final location = LatLng(
        matches.first.latitude,
        matches.first.longitude,
      );
      if (!mounted) return;
      setState(() => _selectedLocation = location);
      _mapController.move(location, 15);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find that place: $error')),
      );
    }
  }

  void _showLocationError(
    String message, {
    LocationAccessException? locationError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: locationError?.canOpenSettings ?? false
            ? SnackBarAction(
                label: 'Settings',
                onPressed: () => _openSettings(locationError!),
              )
            : null,
      ),
    );
  }

  Future<void> _openSettings(LocationAccessException error) async {
    try {
      final opened = await LocationHelper.openSettings(error);
      if (!mounted || opened) return;
      _showLocationError('Could not open settings. Please open them manually.');
    } on Exception catch (error) {
      if (!mounted) return;
      _showLocationError('Could not open settings: $error');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ethiopiaCenter = LatLng(9.145, 40.4897);
    final initialCenter = widget.initialLocation ?? ethiopiaCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose service location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: widget.initialLocation == null ? 5 : 15,
                    onTap: (_, location) {
                      if (LocationHelper.isValidCoordinates(
                        location.latitude,
                        location.longitude,
                      )) {
                        setState(() => _selectedLocation = location);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.frontend',
                    ),
                    if (_selectedLocation case final location?)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location,
                            width: 48,
                            height: 56,
                            child: const Icon(
                              Icons.location_pin,
                              color: Color(0xFF14B8A6),
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.9),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(8),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _searchLocation(),
                            decoration: InputDecoration(
                              hintText: 'Search city or area in Ethiopia',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                onPressed: _searchLocation,
                                icon: const Icon(Icons.arrow_forward),
                                tooltip: 'Search map',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'current-location',
                        onPressed: _isLocating ? null : _useCurrentLocation,
                        tooltip: 'Use current location',
                        child: _isLocating
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selectedLocation == null
                        ? 'Search for a place in Ethiopia, tap the map, or use your current location.'
                        : 'Selected: ${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                            '${_selectedLocation!.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _selectedLocation == null
                        ? null
                        : () => Navigator.pop(context, _selectedLocation),
                    child: const Text('Use this location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
