import 'package:flutter/material.dart';

class ApplyVolunteerScreen extends StatefulWidget {
  const ApplyVolunteerScreen({super.key});

  @override
  State<ApplyVolunteerScreen> createState() => _ApplyVolunteerScreenState();
}

class _ApplyVolunteerScreenState extends State<ApplyVolunteerScreen> {
  final _emailController = TextEditingController();
  final _reasonController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSubmitted = false;

  void _submitApplication() async {
    if (_emailController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        _skillsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call to backend
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _reasonController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Application', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isSubmitted
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
                    const SizedBox(height: 24),
                    Text(
                      "Your application is currently being reviewed.",
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Our team is performing a thorough check. You will receive your unique 12-digit UID once approved.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Home", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Join our team of volunteers and help make a difference! Your skills can save lives.",
                    style: textTheme.bodyLarge?.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Email Address for Updates *"),
                  _buildTextField(
                    controller: _emailController,
                    hint: "Enter your email address...",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel("Why do you want to volunteer? *"),
                  _buildTextField(
                    controller: _reasonController,
                    hint: "Tell us about your motivation...",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel("Your Skills *"),
                  _buildTextField(
                    controller: _skillsController,
                    hint: "e.g., First Aid, Driving, Cooking, etc.",
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel("Previous Experience (Optional)"),
                  _buildTextField(
                    controller: _experienceController,
                    hint: "Tell us about any relevant work you've done...",
                    maxLines: 2,
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _submitApplication,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
        filled: true,
        fillColor: isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
      ),
    );
  }
}
