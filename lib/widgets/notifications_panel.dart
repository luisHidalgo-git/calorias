import 'package:flutter/material.dart';
import '../models/daily_calories.dart';

class NotificationsPanel extends StatefulWidget {
  final List<CalorieEntry> notifications;
  final VoidCallback onClear;

  const NotificationsPanel({
    super.key,
    required this.notifications,
    required this.onClear,
  });

  @override
  _NotificationsPanelState createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.all(screenSize.width * 0.05),
        padding: EdgeInsets.all(screenSize.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade700),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificaciones (${widget.notifications.length})',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onClear,
                      icon: Icon(
                        Icons.clear_all,
                        color: Colors.grey.shade400,
                        size: screenSize.width * 0.05,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade400,
                        size: screenSize.width * 0.05,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(color: Colors.grey.shade700),

            // Lista de notificaciones
            Container(
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.4,
              ),
              child: widget.notifications.isEmpty
                  ? _buildEmptyState(screenSize)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = widget.notifications[widget.notifications.length - 1 - index];
                        return _buildNotificationItem(notification, screenSize);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.08),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: screenSize.width * 0.12,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(CalorieEntry notification, Size screenSize) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.green.shade400,
              size: screenSize.width * 0.04,
            ),
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${notification.calories.toStringAsFixed(1)} calorías',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade300,
                  ),
                ),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.03,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            notification.formattedTime,
            style: TextStyle(
              fontSize: screenSize.width * 0.025,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}