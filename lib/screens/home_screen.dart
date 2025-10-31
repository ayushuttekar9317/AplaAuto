import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ---------- open location bottom sheet ----------
  void _openLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.drag_handle, color: Colors.grey)),
            const SizedBox(height: 10),
            const Text(
              "Set your trip",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Current Location
            _buildLocationField(
              icon: Icons.my_location,
              label: "Current Location",
              hint: "Using GPS",
              color: Colors.green,
            ),
            const SizedBox(height: 15),

            // Drop Location
            _buildLocationField(
              icon: Icons.location_on_outlined,
              label: "Drop Location",
              hint: "Where to?",
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.add_location_alt_outlined,
                color: Colors.deepPurple,
              ),
              label: const Text(
                "Select on Map",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),

            const Divider(height: 25),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
              label: const Text(
                "Add Stops",
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------- location field ----------
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- service icon builder (Font Awesome) ----------
  static Widget _buildServiceIcon(
      IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ---------- image cards ----------
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
                    Colors.black.withOpacity(0.3), BlendMode.darken),
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

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 🔍 Search Bar
              GestureDetector(
                onTap: () => _openLocationBottomSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

              // 🚗 Services Row
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

              // 🏙 Explore Pune
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

              // 🛕 Famous Temples
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
            ]),
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
