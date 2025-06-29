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
                right: -2,
                top: -2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * (isRound ? 0.012 : 0.015),
                    vertical: screenSize.width * (isRound ? 0.008 : 0.01),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(screenSize.width * 0.025),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: screenSize.width * (isRound ? 0.045 : 0.05),
                    minHeight: screenSize.width * (isRound ? 0.045 : 0.05),
                  ),
                  child: Center(
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * (isRound ? 0.025 : 0.028),
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}