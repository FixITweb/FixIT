import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/location_helper.dart';
import 'service_location_picker_screen.dart';

class ServiceLocationSelector extends StatefulWidget {
  final LatLng? location;
  final ValueChanged<LatLng> onChanged;

  const ServiceLocationSelector({
    super.key,
    required this.location,
    required this.onChanged,
  });

  @override
  State<ServiceLocationSelector> createState() =>
      _ServiceLocationSelectorState();
}

class _ServiceLocationSelectorState extends State<ServiceLocationSelector> {
  bool _isLocating = false;
  String? _locationError;
  LocationAccessException? _locationAccessError;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
      _locationAccessError = null;
    });

    try {
      final position = await LocationHelper.getCurrentPosition();
      if (!mounted) return;
      widget.onChanged(LatLng(position.latitude, position.longitude));
    } on LocationAccessException catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = error.message;
        _locationAccessError = error;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Could not get your location: $error';
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _openSettings() async {
    final error = _locationAccessError;
    if (error == null || !error.canOpenSettings) return;

    try {
      final opened = await LocationHelper.openSettings(error);
      if (!mounted || opened) return;
      setState(() {
        _locationError = 'Could not open settings. Please open them manually.';
        _locationAccessError = null;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Could not open settings: $error';
        _locationAccessError = null;
      });
    }
  }

  Future<void> _chooseOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => ServiceLocationPickerScreen(
          initialLocation: widget.location,
        ),
      ),
    );
    if (mounted && selectedLocation != null) {
      widget.onChanged(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Service location *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Customers can see this pin. Choose a public service area if you do not want to share your home location.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isLocating ? null : _useCurrentLocation,
          icon: _isLocating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, size: 18),
          label: Text(
            _isLocating ? 'Finding your location...' : 'Use my location',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isLocating ? null : _chooseOnMap,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: const Text('Choose on map'),
        ),
        if (_locationError != null) ...[
          const SizedBox(height: 4),
          Text(
            _locationError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          if (_locationAccessError?.canOpenSettings ?? false)
            TextButton(
              onPressed: _openSettings,
              child: Text(
                _locationAccessError!.openLocationSettings
                    ? 'Open location settings'
                    : 'Open app settings',
              ),
            ),
        ],
        if (widget.location != null) ...[
          const SizedBox(height: 4),
          Text(
            'Selected: ${widget.location!.latitude.toStringAsFixed(5)}, '
            '${widget.location!.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Choose where customers should find this service.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
