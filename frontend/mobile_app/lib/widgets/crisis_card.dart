import 'package:flutter/material.dart';
import '../models/crisis_model.dart';

class CrisisCard extends StatelessWidget {
  final CrisisModel crisis;

  const CrisisCard({super.key, required this.crisis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crisis.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
              SizedBox(width: 6),
              Text(
                "AI: High urgency",
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(crisis.category),
                backgroundColor: Colors.blue.shade100,
              ),
              const Spacer(),
              const Icon(Icons.people, size: 20, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${crisis.peopleAffected} affected',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
