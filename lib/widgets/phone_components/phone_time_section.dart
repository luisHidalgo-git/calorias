import 'package:flutter/material.dart';
import '../../widgets/adaptive_text.dart';
import '../../utils/color_utils.dart';

class PhoneTimeSection extends StatelessWidget {
  final Color accentColor;

  const PhoneTimeSection({
    super.key,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return AdaptiveText(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                fontSize: screenSize.width * 0.12,
                fontWeight: FontWeight.w300,
                color: accentColor,
                style: TextStyle(letterSpacing: 4.0),
              );
            },
          ),
          SizedBox(height: 8),
          AdaptiveText(
            ColorUtils.getMotivationalText(0), // Placeholder
            fontSize: screenSize.width * 0.045,
            color: accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}