import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _apiService = ApiService();
  String? _issueType;
  String? _urgency;
  final TextEditingController _descController = TextEditingController();
  
  bool _isAnalyzing = false;
  bool _showAiAnalysis = false;
  bool _isSubmitting = false;

  void _getAiAnalysis() async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a description first")));
      return;
    }
    setState(() => _isAnalyzing = true);
    // Simulate AI delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showAiAnalysis = true;
      });
    }
  }

  void _submitReport() async {
    if (_issueType == null || _urgency == null || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiService.createCrisis({
        'title': '$_urgency Urgency $_issueType',
        'description': _descController.text,
        'category': _issueType,
        'people_affected': 10, // Mock based on AI estimate
        'location': {'lat': 20.5937, 'lng': 78.9629},
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted successfully!"), backgroundColor: Colors.green));
        _descController.clear();
        setState(() {
          _issueType = null;
          _urgency = null;
          _showAiAnalysis = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Report an Issue", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Fill in the details below and we'll dispatch help quickly.", style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 24),

            // ── Form Fields ──────────────────────────────────────
            _buildLabel("Issue Type", Icons.category_outlined),
            DropdownButtonFormField<String>(
              value: _issueType,
              hint: const Text("Select issue type"),
              items: ['Medical', 'Shelter', 'Food', 'Fire'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _issueType = v),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            _buildLabel("Urgency Level", Icons.flag_outlined),
            DropdownButtonFormField<String>(
              value: _urgency,
              hint: const Text("Select urgency"),
              items: ['High', 'Medium', 'Low'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _urgency = v),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            _buildLabel("Location", Icons.location_on_outlined),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: _inputDecoration().copyWith(
                      hintText: "Tap to fetch your location",
                      prefixIcon: const Icon(Icons.location_off_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel("Photos / Videos", Icons.photo_library_outlined),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text("Add Photo / Video"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel("Description", Icons.description_outlined),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: _inputDecoration().copyWith(hintText: "Describe the situation in detail..."),
            ),
            const SizedBox(height: 24),

            // ── AI Analysis Section ──────────────────────────────
            if (_isAnalyzing)
              const Center(child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Gemini is analyzing the report...", style: TextStyle(color: Colors.blue)),
                ],
              ))
            else if (_showAiAnalysis)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text("AI Analysis", style: textTheme.titleMedium?.copyWith(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(20)),
                          child: Text("Powered by Gemini", style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text("Several individuals at the local school shelter require basic medical attention for minor cuts and bruises.", style: TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        const Text("Action Priority: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade200)),
                          child: Text("Within 24 hours", style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        const Text("Est. Affected: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("5-10 people"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Suggested Solutions", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildAiListItem("1", "Dispatch a mobile medical kit to the shelter"),
                    _buildAiListItem("2", "Deploy a first aid responder to assess injuries"),
                    _buildAiListItem("3", "Restock basic medical supplies at the facility"),
                    const SizedBox(height: 16),
                    const Text("Skills Required", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildSkillChip("First Aid"),
                        _buildSkillChip("Basic Triage"),
                        _buildSkillChip("Medical Logistics"),
                      ],
                    ),
                  ],
                ),
              )
            else
              Center(
                child: TextButton.icon(
                  onPressed: _getAiAnalysis,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Get AI Analysis Preview"),
                ),
              ),

            const SizedBox(height: 24),

            // ── Submit Button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                label: Text(_isSubmitting ? "Submitting..." : "Submit Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildAiListItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, backgroundColor: Colors.blue.shade100, child: Text(number, style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800))),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.blue.shade800, fontSize: 11)),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade200),
      avatar: Icon(Icons.sell_outlined, color: Colors.blue.shade800, size: 14),
    );
  }
}
