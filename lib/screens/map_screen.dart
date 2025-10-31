import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  final LatLng? destination;
  final List<LatLng>? stops;

  const MapScreen({super.key, this.destination, this.stops});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // put your google api key here (for polyline)
  final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _addMarkersAndRoute();
    _trackMovement();
  }

  void _trackMovement() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _updateCameraPosition();
    });
  }

  Future<void> _updateCameraPosition() async {
    if (_controller.isCompleted && _currentPosition != null) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  Future<void> _addMarkersAndRoute() async {
    if (_currentPosition == null) return;

    final startMarker = Marker(
      markerId: const MarkerId("start"),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: "You are here"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final destinationMarker = widget.destination != null
        ? Marker(
            markerId: const MarkerId("destination"),
            position: widget.destination!,
            infoWindow: const InfoWindow(title: "Drop Location"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          )
        : null;

    Set<Marker> markers = {startMarker};
    if (destinationMarker != null) markers.add(destinationMarker);

    if (widget.stops != null) {
      for (int i = 0; i < widget.stops!.length; i++) {
        markers.add(Marker(
          markerId: MarkerId("stop_$i"),
          position: widget.stops![i],
          infoWindow: InfoWindow(title: "Stop ${i + 1}"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      }
    }

    setState(() {
      _markers = markers;
    });

    if (widget.destination != null) {
      await _drawRoute(_currentPosition!, widget.destination!);
    }
  }
Future<void> _drawRoute(LatLng origin, LatLng destination) async {
  PolylinePoints polylinePoints = PolylinePoints();

  // ✅ New: Create a PolylineRequest object
  final request = PolylineRequest(
    origin: PointLatLng(origin.latitude, origin.longitude),
    destination: PointLatLng(destination.latitude, destination.longitude),
    mode: TravelMode.driving,
  );

  // ✅ Pass the request and API key
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    request: request,
    googleApiKey: apiKey,
  );

  if (result.points.isNotEmpty) {
    List<LatLng> polylineCoordinates = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ),
      );
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Route")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.5,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}
