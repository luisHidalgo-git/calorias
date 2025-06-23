import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final double watchSize;

  const TimeDisplay({
    Key? key,
    required this.watchSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: watchSize * 0.08,
      left: 0,
      right: 0,
      child: Center(
        child: StreamBuilder(
          stream: Stream.periodic(Duration(seconds: 1)),
          builder: (context, snapshot) {
            final now = DateTime.now();
            return Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: watchSize * 0.05,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.8),
              ),
            );
          },
        ),
      ),
    );
  }
}