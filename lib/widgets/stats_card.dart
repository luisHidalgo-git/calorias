import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';
import 'adaptive_text.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return Container(
      padding: EdgeInsets.all(screenSize.width * (isRound ? 0.025 : 0.03)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AdaptiveText(
            title,
            fontSize: screenSize.width * 0.028,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3),
          AdaptiveText(
            value,
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
            color: color,
            overflow: TextOverflow.ellipsis,
          ),
          AdaptiveText(
            unit,
            fontSize: screenSize.width * 0.022,
            color: color.withOpacity(0.7),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}