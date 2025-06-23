import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final double watchSize;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  const ControlButtons({
    Key? key,
    required this.watchSize,
    required this.onAdd,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: watchSize * 0.1,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Add calories button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: watchSize * 0.12,
              height: watchSize * 0.12,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.orange,
                size: watchSize * 0.06,
              ),
            ),
          ),

          // Reset button
          GestureDetector(
            onTap: onReset,
            child: Container(
              width: watchSize * 0.12,
              height: watchSize * 0.12,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Icon(
                Icons.refresh,
                color: Colors.red,
                size: watchSize * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}