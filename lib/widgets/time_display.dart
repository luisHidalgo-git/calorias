import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final double watchSize;
  final Color accentColor;

  const TimeDisplay({
    super.key,
    required this.watchSize,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.04,
        vertical: watchSize * 0.015,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.025),
        color: accentColor.withOpacity(0.12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          return Text(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: watchSize * 0.05,
              fontWeight: FontWeight.w300,
              color: accentColor,
              letterSpacing: 2.0,
            ),
          );
        },
      ),
    );
  }
}
