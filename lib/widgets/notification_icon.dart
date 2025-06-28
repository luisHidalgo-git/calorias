import 'package:flutter/material.dart';
import '../models/daily_calories.dart';

class NotificationIcon extends StatefulWidget {
  final List<CalorieEntry> notifications;
  final VoidCallback onTap;

  const NotificationIcon({
    super.key,
    required this.notifications,
    required this.onTap,
  });

  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.notifications.isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications.isNotEmpty && oldWidget.notifications.isEmpty) {
      _pulseController.repeat(reverse: true);
    } else if (widget.notifications.isEmpty &&
        oldWidget.notifications.isNotEmpty) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = _isRoundScreen(screenSize);
    final hasNotifications = widget.notifications.isNotEmpty;

    return GestureDetector(
      onTap: hasNotifications ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: hasNotifications ? _pulseAnimation.value : 1.0,
            child: Container(
              padding: EdgeInsets.all(
                screenSize.width * (isRound ? 0.02 : 0.025),
              ),
              decoration: BoxDecoration(
                color: hasNotifications
                    ? Colors.red.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasNotifications
                      ? Colors.red.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: hasNotifications
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: hasNotifications
                        ? Colors.red.shade400
                        : Colors.grey.shade500,
                    size: screenSize.width * (isRound ? 0.05 : 0.06),
                  ),
                  if (hasNotifications)
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
                          minHeight:
                              screenSize.width * (isRound ? 0.035 : 0.04),
                        ),
                        child: Text(
                          '${widget.notifications.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                screenSize.width * (isRound ? 0.022 : 0.025),
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
        },
      ),
    );
  }

  bool _isRoundScreen(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    return (aspectRatio > 0.9 && aspectRatio < 1.1);
  }
}
