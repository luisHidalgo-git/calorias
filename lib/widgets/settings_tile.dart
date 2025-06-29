import 'package:flutter/material.dart';
import 'adaptive_text.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade800.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : Colors.grey.shade800.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: enabled
                    ? leading
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Opacity(opacity: 0.5, child: leading),
                      ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdaptiveText(
                      title,
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.white : Colors.grey.shade600,
                    ),
                    SizedBox(height: 2),
                    AdaptiveText(
                      subtitle,
                      fontSize: screenSize.width * 0.035,
                      color: enabled
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8),
                trailing!,
              ] else if (onTap != null && enabled) ...[
                SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
