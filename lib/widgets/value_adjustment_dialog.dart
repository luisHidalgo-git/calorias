import 'package:flutter/material.dart';
import '../utils/device_utils.dart';
import 'adaptive_text.dart';

class ValueAdjustmentDialog extends StatefulWidget {
  final String title;
  final double currentValue;
  final double maxValue;
  final String unit;
  final IconData icon;
  final Color color;
  final Function(double) onValueChanged;

  const ValueAdjustmentDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.maxValue,
    required this.unit,
    required this.icon,
    required this.color,
    required this.onValueChanged,
  });

  @override
  _ValueAdjustmentDialogState createState() => _ValueAdjustmentDialogState();
}

class _ValueAdjustmentDialogState extends State<ValueAdjustmentDialog>
    with SingleTickerProviderStateMixin {
  late double _currentValue;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _updateValue(double newValue) {
    setState(() {
      _currentValue = newValue.clamp(0, widget.maxValue);
    });
  }

  void _applyChanges() {
    widget.onValueChanged(_currentValue);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.getDeviceType(screenSize.width, screenSize.height);
    final isWearable = deviceType == DeviceType.wearable;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: isWearable ? screenSize.width * 0.9 : screenSize.width * 0.85,
              padding: EdgeInsets.all(isWearable ? 16 : 24),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.color.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(screenSize, isWearable),
                  SizedBox(height: isWearable ? 16 : 24),
                  _buildValueDisplay(screenSize, isWearable),
                  SizedBox(height: isWearable ? 16 : 24),
                  _buildSlider(screenSize, isWearable),
                  SizedBox(height: isWearable ? 12 : 16),
                  _buildQuickButtons(screenSize, isWearable),
                  SizedBox(height: isWearable ? 16 : 24),
                  _buildActionButtons(screenSize, isWearable),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Size screenSize, bool isWearable) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isWearable ? 8 : 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: isWearable ? 20 : 24,
          ),
        ),
        SizedBox(width: isWearable ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                widget.title,
                fontSize: screenSize.width * (isWearable ? 0.045 : 0.05),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              AdaptiveText(
                'Ajusta el valor deslizando',
                fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.close,
              color: Colors.grey.shade400,
              size: isWearable ? 16 : 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueDisplay(Size screenSize, bool isWearable) {
    final percentage = (_currentValue / widget.maxValue * 100);
    
    return Container(
      padding: EdgeInsets.all(isWearable ? 16 : 20),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AdaptiveText(
                _currentValue.toStringAsFixed(widget.unit == 'BPM' ? 0 : 1),
                fontSize: screenSize.width * (isWearable ? 0.08 : 0.12),
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
              SizedBox(width: 8),
              AdaptiveText(
                widget.unit,
                fontSize: screenSize.width * (isWearable ? 0.04 : 0.05),
                color: widget.color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 8),
          AdaptiveText(
            '${percentage.toStringAsFixed(1)}% del máximo',
            fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
            color: widget.color.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(Size screenSize, bool isWearable) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.color,
            inactiveTrackColor: widget.color.withOpacity(0.3),
            thumbColor: widget.color,
            overlayColor: widget.color.withOpacity(0.2),
            valueIndicatorColor: widget.color,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: isWearable ? 12 : 14,
            ),
            trackHeight: isWearable ? 4 : 6,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isWearable ? 10 : 12,
            ),
          ),
          child: Slider(
            value: _currentValue,
            min: 0,
            max: widget.maxValue,
            divisions: widget.unit == 'BPM' ? widget.maxValue.toInt() : (widget.maxValue * 10).toInt(),
            label: '${_currentValue.toStringAsFixed(widget.unit == 'BPM' ? 0 : 1)} ${widget.unit}',
            onChanged: _updateValue,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AdaptiveText(
              '0 ${widget.unit}',
              fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
              color: Colors.grey.shade500,
            ),
            AdaptiveText(
              '${widget.maxValue.toStringAsFixed(0)} ${widget.unit}',
              fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButtons(Size screenSize, bool isWearable) {
    final quickValues = widget.unit == 'BPM' 
        ? [60.0, 80.0, 100.0, 120.0, widget.maxValue]
        : [0.0, widget.maxValue * 0.25, widget.maxValue * 0.5, widget.maxValue * 0.75, widget.maxValue];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Valores rápidos:',
          fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickValues.map((value) {
            final isSelected = (_currentValue - value).abs() < 1;
            return GestureDetector(
              onTap: () => _updateValue(value),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWearable ? 8 : 12,
                  vertical: isWearable ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? widget.color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? widget.color.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: AdaptiveText(
                  '${value.toStringAsFixed(widget.unit == 'BPM' ? 0 : 0)}',
                  fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
                  color: isSelected ? widget.color : Colors.grey.shade300,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Size screenSize, bool isWearable) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isWearable ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Center(
                child: AdaptiveText(
                  'Cancelar',
                  fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _applyChanges,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isWearable ? 12 : 16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: AdaptiveText(
                  'Aplicar',
                  fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}