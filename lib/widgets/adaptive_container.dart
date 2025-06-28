import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final bool adaptToRound;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.adaptToRound = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return Container(
      width: width,
      height: height,
      padding: adaptToRound && padding != null 
          ? ScreenUtils.getAdaptivePadding(screenSize, padding!)
          : padding,
      margin: adaptToRound && margin != null
          ? ScreenUtils.getAdaptiveMargin(screenSize, margin!)
          : margin,
      decoration: decoration,
      child: child,
    );
  }
}