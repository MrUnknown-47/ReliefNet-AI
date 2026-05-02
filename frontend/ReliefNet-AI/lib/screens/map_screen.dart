import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../models/crisis_model.dart';

Color getMarkerColor(String? urgencyLevel) {
  switch (urgencyLevel) {
    case "high":
      return Colors.red;
    case "medium":
      return Colors.orange;
    case "low":
      return Colors.green;
    default:
      return Colors.blue;
  }
}

Future<BitmapDescriptor> getMarkerIcon(Color color) async {
  return BitmapDescriptor.defaultMarkerWithHue(
    color == Colors.red
        ? BitmapDescriptor.hueRed
        : color == Colors.orange
            ? BitmapDescriptor.hueOrange
            : color == Colors.green
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueBlue,
  );
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Set<Marker> _markers = {};
  List<CrisisModel> _crisesList = [];
  bool _isLoading = true;
  late AnimationController _controller;
  GoogleMapController? _mapController;

  // Initial camera position: India
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..repeat(reverse: true);

    _fetchAndPlotCrises();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAndPlotCrises() async {
    setState(() => _isLoading = true);
    try {
      final crises = await _apiService.getCrises();

      final Set<Marker> newMarkers = {};
      for (var crisis in crises) {
        if (crisis.location != null) {
          final urgency = crisis.aiAnalysis?['urgency_level'];
          final color = getMarkerColor(urgency);
          final icon = await getMarkerIcon(color);

          newMarkers.add(Marker(
            markerId: MarkerId(crisis.id),
            position: LatLng(crisis.location!.lat, crisis.location!.lng),
            icon: icon,
            infoWindow: InfoWindow(
                title: crisis.title, snippet: "Risk: ${urgency ?? 'unknown'}"),
          ));
        }
      }

      setState(() {
        _markers = newMarkers;
        _crisesList = crises;
        _isLoading = false;
      });

      if (_crisesList.isNotEmpty && _mapController != null) {
        final first = _crisesList.first.location!;
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(first.lat, first.lng),
            8,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading map data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double pulse = 0.5 + (_controller.value * 0.5);
    Set<Circle> currentCircles = {};

    for (var crisis in _crisesList) {
      if (crisis.location != null) {
        final urgency = crisis.aiAnalysis?['urgency_level'];
        if (urgency == "high") {
          currentCircles.add(Circle(
            circleId: CircleId("circle_${crisis.id}"),
            center: LatLng(crisis.location!.lat, crisis.location!.lng),
            radius: 50000 * pulse, // 50km base visibility at zoom 4.5
            fillColor: Colors.red.withOpacity(0.2),
            strokeWidth: 0,
          ));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crisis Map',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            circles: currentCircles,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("🔴 High Risk",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("🟠 Medium Risk",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("🟢 Low Risk",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAndPlotCrises,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
