import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

class WatchButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;
  final bool showBadge;
  final String? badgeText;

  const WatchButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    
    final adaptiveSize = ScreenUtils.getAdaptiveSize(screenSize, size);
    final adaptivePadding = adaptiveSize * 0.022;
    final adaptiveIconSize = adaptiveSize * 0.042;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(adaptivePadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: color,
              size: adaptiveIconSize,
            ),
            if (showBadge && badgeText != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: screenSize.width * (isRound ? 0.035 : 0.04),
                    minHeight: screenSize.width * (isRound ? 0.035 : 0.04),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * (isRound ? 0.022 : 0.025),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}