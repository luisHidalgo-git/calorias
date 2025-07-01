import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/daily_calories.dart';
import '../utils/screen_utils.dart';
import 'watch_button.dart';

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
    final hasNotifications = widget.notifications.isNotEmpty;
    final watchSize = ScreenUtils.getAdaptiveSize(
      screenSize,
      math.min(screenSize.width, screenSize.height) * 0.7,
    );

    return GestureDetector(
      onTap: hasNotifications ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: hasNotifications ? _pulseAnimation.value : 1.0,
            child: WatchButton(
              onTap: hasNotifications ? widget.onTap : () {},
              icon: Icons.notifications_outlined,
              color: hasNotifications ? Colors.red : Colors.grey,
              size: watchSize,
              showBadge: hasNotifications,
              badgeText: hasNotifications
                  ? '${widget.notifications.length}'
                  : null,
            ),
          );
        },
      ),
    );
  }
}
