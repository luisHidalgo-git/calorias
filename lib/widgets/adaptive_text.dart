import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double roundSizeMultiplier;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.roundSizeMultiplier = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    
    final adaptiveFontSize = fontSize != null
        ? (isRound ? fontSize! * roundSizeMultiplier : fontSize!)
        : null;

    return Text(
      text,
      style: style?.copyWith(
        fontSize: adaptiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ) ?? TextStyle(
        fontSize: adaptiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}