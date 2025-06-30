import 'package:flutter/material.dart';
import '../adaptive_text.dart';

class PhoneHeader extends StatelessWidget {
  final Size screenSize;
  final VoidCallback onBack;

  const PhoneHeader({
    super.key,
    required this.screenSize,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade300.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300.withOpacity(0.3)),
          ),
          child: GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back,
              color: Colors.blue.shade300,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                'Historial de Calorías',
                fontSize: screenSize.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              AdaptiveText(
                'Seguimiento diario de actividad',
                fontSize: screenSize.width * 0.04,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}