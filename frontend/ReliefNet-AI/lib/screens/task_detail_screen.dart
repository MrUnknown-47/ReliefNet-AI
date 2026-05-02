import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/crisis_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final CrisisModel crisis;
  const TaskDetailScreen({super.key, required this.crisis});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Mocking status since backend doesn't support it yet
  String _status = 'assigned'; 
  bool _isLoading = false;

  void _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _status = newStatus;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Task status updated to: ${_getStatusLabel(newStatus)}"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getStatusLabel(String status) {
    switch(status) {
      case 'assigned': return 'Assigned';
      case 'in_progress': return 'En Route';
      case 'reached': return 'On Site';
      case 'completed': return 'Completed';
      case 'rejected': return 'Declined';
      default: return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'assigned': return Colors.blue.shade600;
      case 'in_progress': return Colors.orange.shade700;
      case 'reached': return Colors.purple.shade600;
      case 'completed': return Colors.green.shade600;
      case 'rejected': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }

  Color _issueColor(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return Colors.red.shade600;
      case 'food': return Colors.orange.shade700;
      case 'shelter': return Colors.indigo.shade600;
      case 'fire': return Colors.deepOrange.shade600;
      case 'water': return Colors.blue.shade600;
      default: return Colors.blueGrey.shade600;
    }
  }

  IconData _issueIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical': return Icons.medical_services;
      case 'food': return Icons.fastfood;
      case 'shelter': return Icons.house;
      case 'fire': return Icons.local_fire_department;
      case 'water': return Icons.water_drop;
      default: return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final crisis = widget.crisis;
    final issue = crisis.category;
    final description = crisis.description;
    final address = crisis.location != null ? "Lat: ${crisis.location!.lat.toStringAsFixed(4)}, Lng: ${crisis.location!.lng.toStringAsFixed(4)}" : "";
    final color = _issueColor(issue);
    final icon = _issueIcon(issue);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final steps = ['assigned', 'in_progress', 'reached', 'completed'];
    final currentStep = steps.indexOf(_status).clamp(0, 3);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Stepper (Mocked visual)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                final isActive = index <= currentStep;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? color : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crisis.title.isNotEmpty ? crisis.title : issue,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusLabel(_status).toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(_status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Description
            const Text("REPORT DETAILS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Text(
                description.isEmpty ? "No description provided." : description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Location
            if (crisis.location != null) ...[
              const Text("INCIDENT LOCATION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final uri = Uri.parse('google.navigation:q=${crisis.location!.lat},${crisis.location!.lng}&mode=d');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            final fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=${crisis.location!.lat},${crisis.location!.lng}');
                            await launchUrl(fallback);
                          }
                        },
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text("Open in Google Maps", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Action Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_status == 'assigned') ...[
                _buildActionButton("Accept & Start", Icons.directions_run, Colors.blue.shade600, () => _updateStatus('in_progress')),
                const SizedBox(height: 12),
                _buildOutlineActionButton("Decline Task", Colors.red, () => _updateStatus('rejected')),
              ],
              if (_status == 'in_progress') ...[
                _buildActionButton("I've Reached the Site", Icons.location_on, Colors.orange.shade700, () => _updateStatus('reached')),
              ],
              if (_status == 'reached') ...[
                _buildActionButton("Mark as Resolved", Icons.check_circle, Colors.green.shade600, () => _updateStatus('completed')),
              ],
              if (_status == 'completed') ...[
                Center(
                  child: Text(
                    "You have successfully resolved this issue.",
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                  ),
                )
              ],
              if (_status == 'rejected') ...[
                Center(
                  child: Text(
                    "You declined this task.",
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOutlineActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
