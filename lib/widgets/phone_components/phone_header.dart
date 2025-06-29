import 'package:flutter/material.dart';
import '../../models/daily_calories.dart';
import '../../widgets/adaptive_text.dart';

class PhoneHeader extends StatelessWidget {
  final List<CalorieEntry> notifications;
  final VoidCallback onNavigateToTable;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onShowNotifications;
  final Color accentColor;

  const PhoneHeader({
    super.key,
    required this.notifications,
    required this.onNavigateToTable,
    required this.onNavigateToSettings,
    required this.onShowNotifications,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onNavigateToTable,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.table_chart_outlined,
              color: accentColor,
              size: 24,
            ),
          ),
        ),
        AdaptiveText(
          'CalorieWatch',
          fontSize: screenSize.width * 0.06,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onNavigateToSettings,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.grey.shade300,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: onShowNotifications,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notifications.isNotEmpty
                      ? Colors.red.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: notifications.isNotEmpty
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: notifications.isNotEmpty ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    if (notifications.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifications.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}