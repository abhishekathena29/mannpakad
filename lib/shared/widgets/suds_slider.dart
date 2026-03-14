import 'package:flutter/material.dart';
import 'package:mannpakad/core/theme/app_theme.dart';

class SUDSSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  const SUDSSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'SUDs level',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white.withAlpha(50),
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withAlpha(30),
                  valueIndicatorColor: AppColors.primary,
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (newValue) => onChanged(newValue.round()),
                ),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSudsColor(value).withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getSudsColor(value).withAlpha(100)),
              ),
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getSudsColor(int suds) {
    if (suds <= 30) return AppColors.success;
    if (suds <= 50) return AppColors.warning;
    if (suds <= 70) return AppColors.accent;
    return AppColors.error;
  }
}
