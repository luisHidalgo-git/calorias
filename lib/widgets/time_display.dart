import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final double watchSize;
  final Color accentColor;

  const TimeDisplay({
    Key? key,
    required this.watchSize,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: watchSize * 0.08,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: watchSize * 0.04,
            vertical: watchSize * 0.015,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(watchSize * 0.03),
            color: accentColor.withOpacity(0.1),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 10,
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
                  fontWeight: FontWeight.w400,
                  color: accentColor,
                  letterSpacing: 3.0,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}