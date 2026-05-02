import 'package:flutter/material.dart';
import '../models/crisis_model.dart';

class CrisisCard extends StatelessWidget {
  final CrisisModel crisis;

  const CrisisCard({super.key, required this.crisis});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medical': return Icons.medical_services_outlined;
      case 'shelter': return Icons.home_outlined;
      case 'food': return Icons.restaurant_outlined;
      case 'fire': return Icons.local_fire_department_outlined;
      default: return Icons.help_outline;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medical': return Colors.red;
      case 'shelter': return Colors.indigo;
      case 'food': return Colors.orange;
      case 'fire': return Colors.deepOrange;
      default: return Colors.blue;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiAnalysis = crisis.aiAnalysis ?? {};
    final urgency = (aiAnalysis['urgency_level'] ?? 'low').toString();
    final skills = aiAnalysis['skills_needed'] ?? aiAnalysis['needs'] ?? ['General'];
    List<String> skillsList = [];
    if (skills is List) {
      skillsList = skills.map((e) => e.toString()).toList();
    } else {
      skillsList = [skills.toString()];
    }

    final catColor = _getColorForCategory(crisis.category);
    final urgColor = _getUrgencyColor(urgency);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row (Icon, Title, Urgency) ────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForCategory(crisis.category), color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    crisis.title.isNotEmpty ? crisis.title : crisis.category,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: urgColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: urgColor, size: 8),
                      const SizedBox(width: 4),
                      Text(
                        urgency[0].toUpperCase() + urgency.substring(1).toLowerCase(),
                        style: TextStyle(color: urgColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Description ───────────────────────────────────────────
            Text(
              crisis.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // ── Skills Needed ─────────────────────────────────────────
            if (skillsList.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text("Skills needed:", style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                  ...skillsList.take(3).map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sell_outlined, size: 12, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(s, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                      ],
                    ),
                  )),
                ],
              ),
            const SizedBox(height: 16),

            // ── Bottom Row (Distance, Assignment, Time) ───────────────
            Row(
              children: [
                const Icon(Icons.near_me_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                const Text("6 m away", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle_outlined, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Unassigned", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text("14h ago", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Spacer(),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
