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

    _slideAnimation = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  bool _isRoundScreen(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    return (aspectRatio > 0.9 && aspectRatio < 1.1);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = _isRoundScreen(screenSize);

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.all(isRound ? screenSize.width * 0.08 : screenSize.width * 0.04),
          padding: EdgeInsets.all(isRound ? screenSize.width * 0.05 : screenSize.width * 0.04),
          constraints: BoxConstraints(
            maxHeight: isRound ? screenSize.height * 0.6 : screenSize.height * 0.7,
            maxWidth: isRound ? screenSize.width * 0.84 : screenSize.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(isRound ? 20 : 16),
            border: Border.all(color: Colors.grey.shade800, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 4,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(screenSize, isRound),
              SizedBox(height: screenSize.height * (isRound ? 0.015 : 0.02)),
              Flexible(
                child: widget.notifications.isEmpty
                    ? _buildEmptyState(screenSize, isRound)
                    : _buildNotificationsList(screenSize, isRound),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size screenSize, bool isRound) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(screenSize.width * (isRound ? 0.015 : 0.02)),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notifications_active,
            color: Colors.green.shade400,
            size: screenSize.width * (isRound ? 0.04 : 0.05),
          ),
        ),
        SizedBox(width: screenSize.width * (isRound ? 0.025 : 0.03)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: screenSize.width * (isRound ? 0.038 : 0.045),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${widget.notifications.length} actividades recientes',
                style: TextStyle(
                  fontSize: screenSize.width * (isRound ? 0.025 : 0.03),
                  color: Colors.grey.shade400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.notifications.isNotEmpty)
              _buildActionButton(
                icon: Icons.clear_all,
                onTap: widget.onClear,
                color: Colors.orange,
                screenSize: screenSize,
                isRound: isRound,
              ),
            SizedBox(width: screenSize.width * (isRound ? 0.015 : 0.02)),
            _buildActionButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
              color: Colors.grey,
              screenSize: screenSize,
              isRound: isRound,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required MaterialColor color,
    required Size screenSize,
    required bool isRound,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenSize.width * (isRound ? 0.015 : 0.02)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(
          icon, 
          color: color.shade400, 
          size: screenSize.width * (isRound ? 0.032 : 0.04)
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size screenSize, bool isRound) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * (isRound ? 0.06 : 0.08)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * (isRound ? 0.05 : 0.06)),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: screenSize.width * (isRound ? 0.1 : 0.12),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: screenSize.height * (isRound ? 0.015 : 0.02)),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: screenSize.width * (isRound ? 0.035 : 0.04),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: screenSize.height * (isRound ? 0.008 : 0.01)),
          Text(
            'Las actividades aparecerán aquí',
            style: TextStyle(
              fontSize: screenSize.width * (isRound ? 0.028 : 0.032),
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(Size screenSize, bool isRound) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.notifications.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenSize.height * (isRound ? 0.008 : 0.01)),
      itemBuilder: (context, index) {
        final notification =
            widget.notifications[widget.notifications.length - 1 - index];
        return _buildNotificationItem(notification, screenSize, isRound);
      },
    );
  }

  Widget _buildNotificationItem(CalorieEntry notification, Size screenSize, bool isRound) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * (isRound ? 0.028 : 0.035)),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(isRound ? 10 : 12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * (isRound ? 0.02 : 0.025)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.green.shade400,
              size: screenSize.width * (isRound ? 0.032 : 0.04),
            ),
          ),
          SizedBox(width: screenSize.width * (isRound ? 0.028 : 0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+${notification.calories.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: screenSize.width * (isRound ? 0.03 : 0.035),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade300,
                      ),
                    ),
                    SizedBox(width: screenSize.width * (isRound ? 0.012 : 0.015)),
                    Text(
                      'cal',
                      style: TextStyle(
                        fontSize: screenSize.width * (isRound ? 0.025 : 0.03),
                        color: Colors.green.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: screenSize.width * (isRound ? 0.025 : 0.03),
                    color: Colors.grey.shade300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * (isRound ? 0.02 : 0.025),
              vertical: screenSize.height * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              notification.formattedTime,
              style: TextStyle(
                fontSize: screenSize.width * (isRound ? 0.022 : 0.025),
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}