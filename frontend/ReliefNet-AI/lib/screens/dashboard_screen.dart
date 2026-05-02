import 'package:flutter/material.dart';
import '../models/crisis_model.dart';
import '../services/api_service.dart';
import '../widgets/crisis_card.dart';
import 'map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<CrisisModel> _crises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCrises();
  }

  Future<void> _fetchCrises() async {
    setState(() => _isLoading = true);
    try {
      final crises = await _apiService.getCrises();
      setState(() {
        _crises = crises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading crises: $e')),
        );
      }
    }
  }

  void _showCreateCrisisDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final peopleAffectedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🚨 Report Crisis',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: peopleAffectedController,
                  decoration: const InputDecoration(labelText: 'People Affected'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newCrisis = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'people_affected': int.tryParse(peopleAffectedController.text) ?? 0,
                  'location': {'lat': 20.5937, 'lng': 78.9629}, // Default required by backend
                };
                Navigator.pop(context);
                
                try {
                  await _apiService.createCrisis(newCrisis);
                  _fetchCrises(); // Refresh list
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testPredictRisk() async {
    try {
      final response = await _apiService.predictRisk({
        "region": "Assam",
        "rainfall": 80,
        "flood_alert": 1,
        "population_density": 900,
        "past_crises": 10
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Prediction Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Region: ${response['region']}"),
                const SizedBox(height: 8),
                Text(
                  "Risk Level: ${response['prediction']['risk_level'].toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Score: ${response['prediction']['risk_score']}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prediction failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int total = _crises.length;
    int high = _crises.where((c) => (c.aiAnalysis?['urgency_level'] ?? '').toString().toLowerCase() == 'high').length;
    int medium = _crises.where((c) => (c.aiAnalysis?['urgency_level'] ?? '').toString().toLowerCase() == 'medium').length;
    int low = _crises.where((c) => (c.aiAnalysis?['urgency_level'] ?? '').toString().toLowerCase() == 'low').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCrises,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live Reports', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('$total active reports', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Filter Boxes ─────────────────────────────────────────
                  Row(
                    children: [
                      _StatBox(label: 'All', count: total, color: Colors.blue, isSelected: true),
                      const SizedBox(width: 8),
                      _StatBox(label: 'High', count: high, color: Colors.red, isSelected: false),
                      const SizedBox(width: 8),
                      _StatBox(label: 'Medium', count: medium, color: Colors.orange, isSelected: false),
                      const SizedBox(width: 8),
                      _StatBox(label: 'Low', count: low, color: Colors.green, isSelected: false),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Filter Chips ─────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(label: 'Nearest', isSelected: true),
                        _FilterChip(label: 'Latest', isSelected: false),
                        _FilterChip(label: 'Most Urgent', isSelected: false),
                        _FilterChip(label: 'Unassigned Only', isSelected: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Reports List ─────────────────────────────────────────
                  if (_crises.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text('No reports available'),
                    ))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _crises.length,
                      itemBuilder: (context, index) {
                        return CrisisCard(crisis: _crises[index]);
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;

  const _StatBox({required this.label, required this.count, required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
