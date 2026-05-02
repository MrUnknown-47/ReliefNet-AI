import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/crisis_model.dart';
import 'task_detail_screen.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final ApiService _apiService = ApiService();
  List<CrisisModel> _activeTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final crises = await _apiService.getCrises();
      setState(() {
        // For demonstration, we'll treat all fetched crises as active tasks
        _activeTasks = crises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? const Color(0xFF334155) : Colors.white,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                labelColor: isDark ? Colors.white : colorScheme.onSurface,
                unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: "Active"),
                  Tab(text: "Completed"),
                  Tab(text: "Rejected"),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _TaskGrid(
                    tasks: _activeTasks,
                    emptyMessage: "No active tasks right now.",
                    emptyIcon: Icons.assignment_outlined,
                  ),
                  const _TaskGrid(
                    tasks: [],
                    emptyMessage: "No completed tasks yet.",
                    emptyIcon: Icons.check_circle_outline,
                  ),
                  const _TaskGrid(
                    tasks: [],
                    emptyMessage: "No rejected tasks.",
                    emptyIcon: Icons.cancel_outlined,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TaskGrid extends StatelessWidget {
  final List<CrisisModel> tasks;
  final String emptyMessage;
  final IconData emptyIcon;

  const _TaskGrid({
    required this.tasks,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 72,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TaskCard(crisis: tasks[i]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final CrisisModel crisis;
  const _TaskCard({required this.crisis});

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
    final issue = crisis.category;
    final description = crisis.description;
    final color = _issueColor(issue);
    final icon = _issueIcon(issue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    String address = '';
    if (crisis.location != null) {
      address = "Lat: ${crisis.location!.lat.toStringAsFixed(4)}, Lng: ${crisis.location!.lng.toStringAsFixed(4)}";
    }

    // Default to assigned for all
    const statusColor = Color(0xFF3B82F6);
    const statusLabel = 'Assigned';
    const statusIcon = Icons.assignment_ind_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.05 : 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(crisis: crisis)),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Issue Icon and Status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crisis.title.isNotEmpty ? crisis.title : issue,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "Today", // Mock timestamp
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      icon: statusIcon,
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outline.withOpacity(isDark ? 0.05 : 0.05),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description.isNotEmpty) ...[
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (address.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 16,
                            color: isDark ? Colors.blue.shade400 : Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.1) : Colors.blue.shade50.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TASK ID: ${crisis.id.length >= 8 ? crisis.id.substring(0, 8).toUpperCase() : crisis.id}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Details",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
