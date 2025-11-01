// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'route_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = "Fetching current location...";
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "Location services disabled";
          _isGettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permission denied";
          _isGettingLocation = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = "Location permission permanently denied";
          _isGettingLocation = false;
        });
        return;
      }

      // All good: get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode
      String address = await _getAddressFromCoords(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Unable to fetch location";
        _isGettingLocation = false;
      });
    }
  }

  Future<String> _getAddressFromCoords(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return "$lat, $lng";
      final p = placemarks.first;
      // build a readable address; guard against nulls
      final parts = <String>[];
      if ((p.name ?? "").isNotEmpty) parts.add(p.name!);
      if ((p.subLocality ?? "").isNotEmpty) parts.add(p.subLocality!);
      if ((p.locality ?? "").isNotEmpty) parts.add(p.locality!);
      if ((p.subAdministrativeArea ?? "").isNotEmpty)
        parts.add(p.subAdministrativeArea!);
      if ((p.administrativeArea ?? "").isNotEmpty)
        parts.add(p.administrativeArea!);
      if (parts.isEmpty) return p.toString();
      return parts.join(", ");
    } catch (e) {
      return "$lat, $lng";
    }
  }

  // ---------- Bottom sheet that auto-fills pickup and allows editing ----------
  void _openLocationBottomSheet(BuildContext context) async {
    // ensure latest location fetched (refresh)
    if (!_isGettingLocation) {
      // Attempt to refresh location in background before opening sheet
      _initLocation();
    }

    // Local controllers inside the sheet so they don't get recreated on parent rebuilds
    final TextEditingController pickupController = TextEditingController(
      text: _currentAddress,
    );
    final TextEditingController dropController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder to update sheet-local UI (like changing pickup text after manual edit)
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // if the parent updated _currentAddress while sheet is open, keep pickupController in sync:
            if (pickupController.text != _currentAddress &&
                !_isGettingLocation) {
              // only update if user hasn't typed something else (simple heuristic)
              pickupController.text = _currentAddress;
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Set your trip",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Pickup field - shows spinner while fetching, otherwise editable text
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isGettingLocation
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text("Fetching current location..."),
                                  ],
                                ),
                              )
                            : TextField(
                                controller: pickupController,
                                readOnly: false, // editable by user
                                decoration: InputDecoration(
                                  labelText: "Pickup location",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (v) =>
                                    setSheetState(() {}), // allow updates
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Drop field - tap to type or type directly
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dropController,
                          decoration: InputDecoration(
                            labelText: "Drop location",
                            hintText: "Where to?",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: open map picker screen - hook your MapScreen here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Map picker not implemented yet"),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.map_outlined,
                          color: Colors.deepPurple,
                        ),
                        label: const Text(
                          "Select on Map",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: implement add stops UI - currently placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Add Stops not implemented yet"),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.teal,
                        ),
                        label: const Text(
                          "Add Stops",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final pickup = pickupController.text.trim();
                        final drop = dropController.text.trim();

                        if (drop.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter drop location"),
                            ),
                          );
                          return;
                        }

                        // get coordinates for both
                        final pickupPos = await locationFromAddress(pickup);
                        final dropPos = await locationFromAddress(drop);

                        if (pickupPos.isEmpty || dropPos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unable to find route"),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                         builder: (context) => RouteScreen(
  pickupLatLng: LatLng(
    pickupPos.first.latitude,
    pickupPos.first.longitude,
  ),
  dropLatLng: LatLng(
    dropPos.first.latitude,
    dropPos.first.longitude,
  ),
),

                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm Location",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- UI helpers (unchanged) ----------
  static Widget _buildLocationField({
    required IconData icon,
    required String label,
    required String hint,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildServiceIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static Widget _buildImageCards(List<Map<String, String>> items) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(item["img"]!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item["title"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- main build (keeps your existing layout) ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar opens the bottom sheet
                GestureDetector(
                  onTap: () => _openLocationBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.deepPurple),
                        SizedBox(width: 10),
                        Text(
                          "Where are you going?",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceIcon(
                      FontAwesomeIcons.taxi,
                      'Auto',
                      Colors.deepPurple,
                    ),
                    _buildServiceIcon(
                      FontAwesomeIcons.peopleGroup,
                      'Shared Auto',
                      Colors.teal,
                    ),
                    _buildServiceIcon(
                      FontAwesomeIcons.boxOpen,
                      'Parcel',
                      Colors.orange,
                    ),
                    _buildServiceIcon(
                      FontAwesomeIcons.carOn,
                      'Book 2+ Autos',
                      Colors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                const Text(
                  "Explore Pune",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildImageCards([
                  {
                    "title": "Shaniwar Wada",
                    "img": "assets/images/background/shaniwar_wada.jpg",
                  },
                  {
                    "title": "Aga Khan Palace",
                    "img": "assets/images/background/aga_khan_palace.jpg",
                  },
                  {
                    "title": "Sinhagad Fort",
                    "img": "assets/images/background/sinhagad.jpg",
                  },
                  {
                    "title": "Pataleshwar Caves",
                    "img": "assets/images/background/pataleshwar.jpg",
                  },
                ]),

                const SizedBox(height: 28),

                const Text(
                  "Famous Temples",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildImageCards([
                  {
                    "title": "Dagadusheth Temple",
                    "img": "assets/images/background/dagadusheth.jpg",
                  },
                  {
                    "title": "Chaturshringi Temple",
                    "img": "assets/images/background/chaturshringi.jpg",
                  },
                  {
                    "title": "Omkareshwar",
                    "img": "assets/images/background/omkareshwar.jpg",
                  },
                  {
                    "title": "Neelkantheshwar",
                    "img": "assets/images/background/neelkantheshwar.jpg",
                  },
                ]),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: "Services",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
