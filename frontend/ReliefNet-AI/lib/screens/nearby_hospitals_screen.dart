import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// Note: In a real app, you would use Geolocator to get coordinates
// and a backend service to query Google Places or Gemini for hospitals.

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _hospitals = [];
  final String _currentAddress = "Sector 14, City Center";

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    setState(() => _isLoading = true);
    // Simulate network delay and mock data
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _hospitals = [
          {
            'name': 'City General Hospital',
            'address': '123 Main St, Sector 14',
            'distance': '1.2',
            'rating': '4.5',
            'phone': '+1234567890',
            'lat': 20.5937,
            'lng': 78.9629,
          },
          {
            'name': 'Hope Medical Center',
            'address': '45 Park Ave, Sector 12',
            'distance': '2.8',
            'rating': '4.8',
            'phone': '+1987654321',
            'lat': 20.5950,
            'lng': 78.9600,
          },
          {
            'name': 'Sunrise Care Clinic',
            'address': '78 East Rd, Sector 15',
            'distance': '3.5',
            'rating': '4.2',
            'phone': 'N/A',
            'lat': 20.5900,
            'lng': 78.9650,
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    if (phoneNumber == 'N/A') return;
    final url = 'tel:${phoneNumber.replaceAll(RegExp(r'[^\d+]'), '')}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchDirections(String hospitalName, String address) async {
    final query = Uri.encodeComponent("$hospitalName, $address");
    final url = "https://www.google.com/maps/search/?api=1&query=$query";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'] ?? "Hospital",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital['address'] ?? "",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoChip(Icons.star, Colors.amber, "${hospital['rating']} Rating"),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.directions_walk, Colors.blue, "${hospital['distance']} km away"),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: hospital['phone'] != 'N/A' ? () => _makeCall(hospital['phone']) : null,
                    icon: const Icon(Icons.phone),
                    label: const Text("Call"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _launchDirections(hospital['name'] ?? '', hospital['address'] ?? ''),
                    icon: const Icon(Icons.directions),
                    label: const Text("Navigate"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(isDark ? 0.2 : 1),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text("Locating your current area...", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _currentAddress,
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHospitals,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(isDark ? 0.2 : 1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentAddress,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hospitals within 7km radius",
                          style: textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _hospitals.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text("No hospitals found in this area.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text("Try refreshing or checking your GPS.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _hospitals.length,
                            itemBuilder: (context, index) {
                              final hospital = _hospitals[index];
                              return InkWell(
                                onTap: () => _showHospitalDetails(hospital),
                                borderRadius: BorderRadius.circular(16),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.local_hospital, color: Colors.red),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hospital['name'] ?? "Unknown Hospital",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                hospital['address'] ?? "Address not available",
                                                style: textTheme.bodySmall?.copyWith(fontSize: 11),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      "${hospital['distance']} km",
                                                      style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.star, size: 12, color: Colors.amber),
                                                  Text(" ${hospital['rating']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (hospital['phone'] != null && hospital['phone'] != 'N/A')
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.green.withOpacity(0.1),
                                              padding: const EdgeInsets.all(8),
                                            ),
                                            icon: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                                            onPressed: () => _makeCall(hospital['phone']),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
