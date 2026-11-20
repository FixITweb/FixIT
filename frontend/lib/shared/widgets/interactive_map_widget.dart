import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class InteractiveMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String workerName;
  final double distance;

  const InteractiveMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.workerName,
    required this.distance,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  final String _mapViewType = 'map-view';

  @override
  void initState() {
    super.initState();
    _registerMapView();
  }

  void _registerMapView() {
    // Register the iframe for web
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _mapViewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..src = _getMapEmbedUrl();
        return iframe;
      },
    );
  }

  String _getMapEmbedUrl() {
    // Using OpenStreetMap (free alternative to Google Maps)
    return 'https://www.openstreetmap.org/export/embed.html?'
        'bbox=${widget.longitude - 0.01},${widget.latitude - 0.01},'
        '${widget.longitude + 0.01},${widget.latitude + 0.01}'
        '&layer=mapnik'
        '&marker=${widget.latitude},${widget.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Embedded Map
            HtmlElementView(viewType: _mapViewType),

            // Location Info Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainer : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outlineVariant.withOpacity(0.4)
                        : colorScheme.outlineVariant.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.distance.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Get Directions Button
            Positioned(
              bottom: 12,
              right: 12,
              child: ElevatedButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
    }
  }
}
