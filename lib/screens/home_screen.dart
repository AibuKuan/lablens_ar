import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- New Helper function to parse bold text (**) from a string ---
  Widget _buildDetailText(String text, Color color) {
    // Regex to find text enclosed in **
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final List<TextSpan> spans = [];
    int currentPosition = 0;

    for (final match in boldRegex.allMatches(text)) {
      // 1. Add non-bold text before the match
      if (match.start > currentPosition) {
        spans.add(TextSpan(text: text.substring(currentPosition, match.start)));
      }

      // 2. Add the bold text (group 1 is the content inside **)
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      // Update position to the end of the match
      currentPosition = match.end;
    }

    // 3. Add any remaining non-bold text after the last match
    if (currentPosition < text.length) {
      spans.add(TextSpan(text: text.substring(currentPosition)));
    }

    // Now, build the Row with the icon and the parsed RichText
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.5), // Default style
                children: spans,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper function to build a feature tile ---
  Widget _buildFeatureTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<String> details,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        collapsedIconColor: Colors.black54,
        iconColor: color,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Use the new _buildDetailText function here
              children: details.map((detail) => _buildDetailText(detail, color)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          // --- KLD Logo/Image ---
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              'assets/kld.png',
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          
          // --- Introduction Text ---
          Text(
            "AR Learning Tool 🎓",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "At Kolehiyo ng Lungsod ng Dasmarinas (KLD), we're building tools to make learning easier for nursing students. Our Augmented Reality (AR) Learning Tool was created by a team of IS students in partnership with the Nursing Department. It tackles issues like limited lab equipment, student fears about handling tools, and the need for more hands-on practice.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            "The app uses QR codes to show 3D models of lab tools on phones—no internet required. Students can zoom in, rotate, and learn how each tool works through simple visuals and descriptions.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          
          // --- Manual Section Header ---
          const Text(
            "User Guide & Features",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(thickness: 2, height: 20),
          
          // --- Manual Features List ---
          _buildFeatureTile(
            icon: Icons.qr_code_scanner,
            color: Colors.green.shade700,
            title: 'Scanner',
            subtitle: 'Scan QR codes to launch 3D models in Augmented Reality.',
            details: [
              'Use this module to scan a QR code associated with an equipment.',
              'The scan will automatically load the equipment\'s 3D model and show it in either Augmented Reality mode or the 3D Viewer.',
            ],
          ),
          
          _buildFeatureTile(
            icon: Icons.videocam,
            color: Colors.orange.shade700,
            title: 'AR Camera',
            subtitle: 'Place and interact with 3D models in your real-world environment.',
            details: [
              'This feature requires a phone with **AR support**.',
              'Ensure you are on a **clear, flat surface** and slowly scan the area until **dotted planes** appear.',
              'Tap on a dotted plane to place the 3D model.',
              'Use the **slider** on the screen to resize the model (zoom in/out).',
              '**Slide up** while in AR view to view the detailed information about the model.',
            ],
          ),
          
          _buildFeatureTile(
            icon: Icons.menu_book,
            color: Colors.purple.shade700,
            title: 'Library',
            subtitle: 'Access all available models without needing a QR code.',
            details: [
              'This section lists all available 3D equipment models.',
              'Select a model from the list to view it directly in AR or the Model Viewer.',
            ],
          ),
          
          _buildFeatureTile(
            icon: Icons.view_in_ar,
            color: Colors.teal.shade700,
            title: 'Model Viewer',
            subtitle: 'Interactive learning for devices without AR support.',
            details: [
              'This feature is available for phones that **do not have AR support**.',
              'It provides an interactive 3D view of the equipment with buttons and animations to aid in learning.',
              'You can still rotate, zoom, and view details in this mode.',
            ],
          ),
          
          const SizedBox(height: 20),
          // --- Conclusion Text ---
          Text(
            "This project reflects KLD's mission to use technology for better education. We aim to prepare future nurses with confidence and practical knowledge.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}