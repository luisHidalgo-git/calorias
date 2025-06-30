import 'package:flutter/material.dart';
import '../../utils/screen_utils.dart';
import '../adaptive_text.dart';

class TableHeader extends StatelessWidget {
  final Size screenSize;
  final bool isRound;

  const TableHeader({
    super.key,
    required this.screenSize,
    required this.isRound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * (isRound ? 0.025 : 0.03),
        vertical: screenSize.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AdaptiveText(
              'Fecha',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: AdaptiveText(
              'Calorías',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: AdaptiveText(
              'Estado',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}