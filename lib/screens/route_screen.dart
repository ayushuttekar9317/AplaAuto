import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteScreen extends StatefulWidget {
  final LatLng pickupLatLng;
  final LatLng dropLatLng;

  const RouteScreen({
    Key? key,
    required this.pickupLatLng,
    required this.dropLatLng,
  }) : super(key: key);

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    _markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: widget.pickupLatLng,
      infoWindow: const InfoWindow(title: 'Pickup Location'),
    ));

    _markers.add(Marker(
      markerId: const MarkerId('drop'),
      position: widget.dropLatLng,
      infoWindow: const InfoWindow(title: 'Drop Location'),
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(widget.pickupLatLng, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Screen')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.pickupLatLng,
          zoom: 12,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
