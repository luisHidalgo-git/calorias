import 'package:flutter/material.dart';
import '../models/fitness_data.dart';

class CenterContent extends StatelessWidget {
  final FitnessData fitnessData;
  final double watchSize;

  const CenterContent({
    Key? key,
    required this.fitnessData,
    required this.watchSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: watchSize * 0.6,
        height: watchSize * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calories counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: watchSize * 0.06,
                ),
                SizedBox(width: 8),
                Text(
                  '${fitnessData.calories.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: watchSize * 0.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            Text(
              'CALORÍAS',
              style: TextStyle(
                fontSize: watchSize * 0.025,
                color: Colors.orange.withOpacity(0.8),
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: watchSize * 0.04),

            // Distance and Heart Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Distance
                Column(
                  children: [
                    Text(
                      '${fitnessData.distance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: watchSize * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        fontSize: watchSize * 0.025,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Heart Rate
                Column(
                  children: [
                    Text(
                      '${fitnessData.heartRate}',
                      style: TextStyle(
                        fontSize: watchSize * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'bpm',
                      style: TextStyle(
                        fontSize: watchSize * 0.025,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}