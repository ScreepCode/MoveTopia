import 'package:activity_tracking/model/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingMap extends HookConsumerWidget {
  final Activity? activity;

  const TrackingMap({super.key, this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    getPoints(Activity activity) {
      return activity.locations?.values.map((location) {
        return LatLng(location.latitude, location.longitude);
      }).toList();
    }

    calculateInitialCenter(Activity activity) {
      if (activity.locations == null || activity.locations!.isEmpty) {
        return const LatLng(0.0, 0.0); // Default center if no locations
      }
      final firstLocation = activity.locations!.values.first;
      return LatLng(firstLocation.latitude, firstLocation.longitude);
    }

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 300,
              child: activity != null &&
                      activity?.locations != null &&
                      activity!.locations!.isNotEmpty
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: calculateInitialCenter(activity!),
                        initialZoom: 15.0,
                      ),
                      children: [
                          const SimpleAttributionWidget(
                            source: Text('OpenStreetMap contributors'),
                          ),
                          TileLayer(
                            userAgentPackageName: "de.buseslaar.movetopia",
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          RichAttributionWidget(
                            attributions: [
                              // Suggested attribution for the OpenStreetMap public tile server
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () => launchUrl(Uri.parse(
                                    'https://openstreetmap.org/copyright')),
                              ),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: getPoints(activity!) ?? [],
                                strokeWidth: 4.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ],
                          ),
                        ])
                  : Center(
                      child: Text(
                        l10n.tracking_no_map,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            )));
  }
}
