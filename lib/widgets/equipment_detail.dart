import 'package:ar_app/models/equipment.dart';
import 'package:flutter/material.dart'; // Needed for Theme, Text, Column, etc.


class EquipmentDetail extends StatelessWidget {
  final Equipment detail;

  const EquipmentDetail({super.key, required this.detail});

  /// Helper method to build a section (Title + Content) only if content is not null or empty.
  Widget _buildSection(String title, String? content) {
    // Check if content is non-null and not just whitespace
    if (content != null && content.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 6),
            // Content
            Text(
              content.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4, // Improves readability for long text
              ),
            ),
          ],
        ),
      );
    }
    // Return an empty widget if content is null or empty
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the details in a SingleChildScrollView so it can scroll within the draggable sheet
    return SingleChildScrollView(
      // Add padding to the entire view
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Title
          Text(
            detail.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(height: 30, thickness: 1.5, color: Colors.blueAccent),

          // Build all descriptive sections, automatically skipping empty ones
          _buildSection('Category', detail.category),
          _buildSection('Function', detail.function),
          _buildSection('Usage', detail.usage),
          _buildSection('Specifications', detail.specifications),
          _buildSection('Maintenance', detail.maintenance),
          _buildSection('Warning/Safety', detail.warning),
        ],
      ),
    );
  }
}