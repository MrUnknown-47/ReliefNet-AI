import 'package:flutter/material.dart';
import '../models/crisis_model.dart';
import '../services/api_service.dart';
import '../widgets/crisis_card.dart';

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
                  'location': {'lat': 0.0, 'lng': 0.0}, // Default required by backend
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'ReliefNet AI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Test Prediction',
            onPressed: _testPredictRisk,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCrises,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            )
          : _crises.isEmpty
              ? const Center(child: Text('No crisis reports found.'))
              : ListView.builder(
                  itemCount: _crises.length,
                  itemBuilder: (context, index) {
                    return CrisisCard(crisis: _crises[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCrisisDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
