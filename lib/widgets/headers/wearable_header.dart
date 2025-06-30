import 'package:flutter/material.dart';
import '../../utils/screen_utils.dart';
import '../adaptive_text.dart';
import '../watch_button.dart';
import 'dart:math' as math;

class WearableHeader extends StatelessWidget {
  final Size screenSize;
  final bool isRound;
  final VoidCallback onBack;

  const WearableHeader({
    super.key,
    required this.screenSize,
    required this.isRound,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final watchSize = ScreenUtils.getAdaptiveSize(
      screenSize,
      math.min(screenSize.width, screenSize.height) * 0.7,
    );

    if (isRound) {
      return Column(
        children: [
          Center(
            child: WatchButton(
              onTap: onBack,
              icon: Icons.arrow_back,
              color: Colors.blue.shade300,
              size: watchSize,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Center(
            child: Column(
              children: [
                AdaptiveText(
                  'Historial de Calorías',
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                AdaptiveText(
                  'Seguimiento diario de actividad',
                  fontSize: screenSize.width * 0.024,
                  color: Colors.grey.shade400,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          WatchButton(
            onTap: onBack,
            icon: Icons.arrow_back,
            color: Colors.blue.shade300,
            size: watchSize,
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  'Historial de Calorías',
                  fontSize: screenSize.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                AdaptiveText(
                  'Seguimiento diario de actividad',
                  fontSize: screenSize.width * 0.032,
                  color: Colors.grey.shade400,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}