import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_screen.dart'; // We'll navigate here if needed
import 'report_issue_screen.dart';
import 'nearby_hospitals_screen.dart';
import 'apply_volunteer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _makeEmergencyCall(BuildContext context, String serviceName, String number) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text("Emergency Call"),
            ],
          ),
          content: Text("Are you sure you want to dial $serviceName ($number)?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Call Now"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final Uri uri = Uri(scheme: 'tel', path: number);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showError(context, "Could not open dialer for $number.");
        }
      } catch (e) {
        _showError(context, "Failed to dial: $e");
      }
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReliefNet', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header ──────────────────────────────────────
            Text("Hello, Volunteer 👋", style: textTheme.bodyLarge),
            Text("You're an active volunteer.", style: textTheme.bodyMedium),
            const SizedBox(height: 20),

            // ── Report an Issue Button ─────────────────────────────
            GestureDetector(
              onTap: () => _navigateToReport(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade300.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Report an Issue",
                            style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Need help? Let us know immediately.",
                            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Emergency Quick Actions ──────────────────────────
            const _SectionHeader(title: "Quick Emergency Actions", icon: Icons.bolt_rounded),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _EmergencyActionBtn(
                  icon: Icons.local_hospital_outlined,
                  label: "Hospitals",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen()));
                  },
                ),
                _EmergencyActionBtn(
                  icon: Icons.local_police_outlined,
                  label: "Police",
                  color: Colors.blue,
                  onTap: () => _makeEmergencyCall(context, 'Police', '100'),
                ),
                _EmergencyActionBtn(
                  icon: Icons.medical_services_outlined,
                  label: "Ambulance",
                  color: Colors.red,
                  onTap: () => _makeEmergencyCall(context, 'Ambulance', '102'),
                ),
                _EmergencyActionBtn(
                  icon: Icons.local_fire_department_outlined,
                  label: "Fire",
                  color: Colors.orange,
                  onTap: () => _makeEmergencyCall(context, 'Fire Brigade', '101'),
                ),
                _EmergencyActionBtn(
                  icon: Icons.sos_rounded,
                  label: "SOS",
                  color: Colors.red.shade900,
                  onTap: () => _makeEmergencyCall(context, 'Emergency SOS', '112'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Safety Tips Carousel ─────────────────────────────
            const _SectionHeader(title: "Safety & Preparedness", icon: Icons.security_rounded),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _SafetyTipCard(
                    title: "Earthquake Safety",
                    desc: "Drop, Cover, and Hold On! Stay away from glass.",
                    icon: Icons.terrain_rounded,
                    color: Colors.brown,
                  ),
                  _SafetyTipCard(
                    title: "First Aid Basics",
                    desc: "Keep a kit ready with bandages, antiseptic, and meds.",
                    icon: Icons.health_and_safety_rounded,
                    color: Colors.teal,
                  ),
                  _SafetyTipCard(
                    title: "Fire Emergency",
                    desc: "Crawl low under smoke and use stairs, not elevators.",
                    icon: Icons.fireplace_rounded,
                    color: Colors.deepOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Community Impact ─────────────────────────────────
            _ImpactSummaryCard(isDark: isDark),
            const SizedBox(height: 24),

            // ── Apply to Volunteer Banner ────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplyVolunteerScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                      child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Become a Volunteer", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          const SizedBox(height: 4),
                          Text("Join the frontline and help your community.", style: textTheme.bodySmall?.copyWith(color: Colors.blue.shade900)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── My Active Reports ──────────────────────────────────
            const _SectionHeader(title: "My Active Reports", icon: Icons.list_alt_rounded),
            const SizedBox(height: 10),
            const _EmptyState(
              icon: Icons.inbox_rounded,
              message: "No active reports. You're all caught up!",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Shared Section Header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Emergency Action Button ──────────────────────────────────────────────────
class _EmergencyActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_EmergencyActionBtn> createState() => _EmergencyActionBtnState();
}

class _EmergencyActionBtnState extends State<_EmergencyActionBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Safety Tip Card ──────────────────────────────────────────────────────────
class _SafetyTipCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _SafetyTipCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Impact Summary Card ──────────────────────────────────────────────────────
class _ImpactSummaryCard extends StatelessWidget {
  final bool isDark;
  const _ImpactSummaryCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [Colors.blueGrey.shade800, Colors.blueGrey.shade900]
            : [Colors.indigo.shade50, Colors.indigo.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Community Impact",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ImpactStat(label: "Resolved", value: "1.2k", color: Colors.green),
              _ImpactStat(label: "Volunteers", value: "450+", color: Colors.blue),
              _ImpactStat(label: "Active", value: "84", color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ImpactStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
