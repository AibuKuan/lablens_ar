import 'package:lablens_ar/models/equipment.dart';
import 'package:flutter/material.dart';

class EquipmentDetail extends StatelessWidget {
  final Equipment detail;

  const EquipmentDetail({super.key, required this.detail});

  /// 1. Helper method for simple text sections (Function, Usage).
  Widget _buildTextSection(String title, String? content, Color titleColor) {
    if (content != null && content.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// 2. Helper method for the compact Category tag.
  Widget _buildTag(BuildContext context, String? category) {
    if (category != null && category.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Text(
            category.trim().toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// 3. Helper method for the prominent Card sections (Specifications, Maintenance, Warning).
  Widget _buildCardSection(
    String title,
    String? content,
    IconData icon,
    Color titleColor,
    Color cardColor,
  ) {
    if (content != null && content.trim().isNotEmpty) {
      // Define styles for content
      TextStyle contentStyle = const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        height: 1.5,
      );

      // Special handling for the Warning/Safety section
      if (title == 'Warning/Safety') {
        titleColor = Colors.white; // White title text for the red background
        contentStyle = contentStyle.copyWith(color: Colors.white70); // Light content text
      }

      return Card(
        elevation: 6.0,
        margin: const EdgeInsets.only(bottom: 18.0),
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: title == 'Warning/Safety'
              ? BorderRadius.circular(10.0) // Sharper for Warning
              : BorderRadius.circular(14.0), // Standard for others
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: titleColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 0.5, color: Colors.white38),
              Text(
                content.trim(),
                style: contentStyle,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    // Define styles for Card sections
    final Map<String, dynamic> cardStyles = {
      'Specifications': {
        'icon': Icons.tune_outlined,
        'titleColor': Colors.deepOrange,
        'cardColor': Colors.orange.shade50,
        'content': detail.specifications,
      },
      'Maintenance': {
        'icon': Icons.handyman_outlined,
        'titleColor': Colors.green.shade700,
        'cardColor': Colors.lightGreen.shade50,
        'content': detail.maintenance,
      },
      'Warning/Safety': {
        'icon': Icons.warning_amber_outlined,
        'titleColor': Colors.red.shade100,
        'cardColor': Colors.red.shade700,
        'content': detail.warning,
      },
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN HEADER
          Text(
            detail.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: secondaryColor,
            ),
          ),
          
          // CATEGORY TAG (New smaller style)
          const SizedBox(height: 10),
          _buildTag(context, detail.category),
          
          const Divider(height: 10, thickness: 2.0, color: Colors.blueAccent),
          const SizedBox(height: 20),

          // FUNCTION (Simple text section)
          _buildTextSection('Function', detail.function, primaryColor),

          // USAGE (Simple text section)
          _buildTextSection('Usage', detail.usage, primaryColor),

          // --- CARD SECTIONS START HERE ---
          
          // SPECIFICATIONS (Prominent Card)
          _buildCardSection(
            'Specifications',
            cardStyles['Specifications']['content'] as String?,
            cardStyles['Specifications']['icon'] as IconData,
            cardStyles['Specifications']['titleColor'] as Color,
            cardStyles['Specifications']['cardColor'] as Color,
          ),

          // MAINTENANCE (Prominent Card)
          _buildCardSection(
            'Maintenance',
            cardStyles['Maintenance']['content'] as String?,
            cardStyles['Maintenance']['icon'] as IconData,
            cardStyles['Maintenance']['titleColor'] as Color,
            cardStyles['Maintenance']['cardColor'] as Color,
          ),

          // WARNING/SAFETY (Distinct Red Card)
          _buildCardSection(
            'Warning/Safety',
            cardStyles['Warning/Safety']['content'] as String?,
            cardStyles['Warning/Safety']['icon'] as IconData,
            cardStyles['Warning/Safety']['titleColor'] as Color,
            cardStyles['Warning/Safety']['cardColor'] as Color,
          ),
        ],
      ),
    );
  }
}