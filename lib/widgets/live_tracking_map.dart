import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/service_request.dart';
import '../theme/app_theme.dart';

class LiveTrackingMap extends StatelessWidget {
  final ServiceRequest request;
  final double height;

  const LiveTrackingMap({
    super.key,
    required this.request,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng customerPos = LatLng(request.latitude, request.longitude);
    final LatLng providerPos = LatLng(
      request.providerLat ?? (request.latitude + 0.008),
      request.providerLng ?? (request.longitude + 0.008),
    );

    // Calculate map bounds center
    final LatLng center = LatLng(
      (customerPos.latitude + providerPos.latitude) / 2,
      (customerPos.longitude + providerPos.longitude) / 2,
    );

    final List<LatLng> polylinePoints = [
      providerPos,
      LatLng(
        (providerPos.latitude + customerPos.latitude) / 2 + 0.001,
        (providerPos.longitude + customerPos.longitude) / 2 - 0.001,
      ),
      customerPos,
    ];

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fixnear.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Customer Pin
                    Marker(
                      point: customerPos,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Provider Pin (if assigned)
                    if (request.status != RequestStatus.pending)
                      Marker(
                        point: providerPos,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.providerRole,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 10),
                            ],
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Top Status / ETA Header Card
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            request.status == RequestStatus.pending
                                ? 'Finding Nearby Providers...'
                                : 'Provider En Route',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            request.status == RequestStatus.pending
                                ? 'Estimated arrival ~10-15 mins'
                                : 'ETA: 6 mins (1.4 miles away)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
}
